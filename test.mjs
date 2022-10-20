/***
 *
 * Makin a tester for Multitor running
 *
 * docker run --name mytor-200tor  -e "TOR_INSTANCES=5"  -d -p 15379-15579:15379-15579  -p 16379:16379 -p 16380:16380 multitor-node-ha
 */
import got from "got"
import { HttpsProxyAgent, HttpProxyAgent } from "hpagent"
import { FingerprintGenerator } from "fingerprint-generator"
let fingerprintGenerator = new FingerprintGenerator({
  browsers: [
    { name: "firefox", minVersion: 80 },
    { name: "chrome", minVersion: 87 },
    "safari",
  ],
  devices: ["desktop"],
  operatingSystems: ["windows", "linux"],
})

const maxPerLoop = 5
let ipUrl = "https://ipinfo.io/ip"

async function main() {
  let resArray = []
  console.time("promiseAll")
  let reqArray = []
  let step = 0
  for (let i = 0; i < 5; i++) {
    step++
    let makeUrl = `${ipUrl}?i=${i}`
    reqArray.push(
      gotWrapper(makeUrl).catch((error) => {
        console.log(`error handeled in push req number #${i}`, error.message)
        console.log(`error?.code #${i}`, error?.code)
      }),
    )

    if (reqArray.length === maxPerLoop) {
      try {
        //resArray = await Promise.all(reqArray)
        //parsResponse(resArray)
        runAll(reqArray)
        reqArray = []

        step = 0
        await new Promise((resolve) => setTimeout(resolve, 500))
      } catch (e) {
        console.log("error in promise all :>> ", e.message)
      }
      //console.log("resArray :>> ", resArray)
    }
    step++
  }

  if (reqArray.length) {
    resArray = await Promise.all(reqArray)
    if (resArray.length) parsResponse(resArray)
  }

  console.timeEnd("promiseAll")
  console.log("Ended")
}

async function runAll(reqArray) {
  try {
    let resArray = await Promise.all(reqArray)
    if (resArray.length) parsResponse(resArray)
  } catch (error) {
    console.log("[runAll] error.message :>> ", error.message)
  }
}

function parsResponse(resArray) {
  resArray.forEach((e) => {
    if (!e) return
    let { body, statusCode } = e
    if (body) console.log(`IP :>> ${statusCode} => `, body ?? "")
    //console.log(`IP :>> ${statusCode} => `)
  })
}
async function gotWrapper(url) {
  try {
    return got(url, {
      headers: fingerprintGenerator.getHeaders(),
      agent: {
        https: new HttpsProxyAgent({
          keepAlive: false,
          //keepAliveMsecs: 1000,
          //maxSockets: 2560,
          //maxFreeSockets: 2560,
          //scheduling: "fifo",
          proxy: "http://127.0.0.1:16379", // ha >> polipo >tor
          //proxy: "http://localhost.1.43:15379", // polipo > tor inside docker
        }),
      },
      // retry: { limit: 2 },
      retry: {
        limit: 2,
        errorCodes: [
          ...got.defaults.options.retry.errorCodes,
          "ERR_GOT_REQUEST_ERROR",
          "GOT_REQUEST_ERROR",
        ],
      },
      timeout: {
        lookup: 500,
        connect: 1000,
        secureConnect: 50,
        socket: 10000,
        send: 10000,
        response: 14000,
      },
      throwHttpErrors: false,
      hooks: {
        beforeError: [
          (error) => {
            const { response } = error
            if (response && response.body) {
              //await new Promise((f) => setTimeout(f, 800))
              console.log("before error hook ", response.statusCode)
            } else {
              //console.log("in Before Error Hook ", error?.code)
              //return new Error("custom error")
            }

            return error
          },
        ],
      },
    })
  } catch (e) {
    //console.log("error :>> ", e.message)
    console.log("error In got wrapper :>> ", e.message)
    return { body: "some error", statusCode: 500 }
  }
}

main()
