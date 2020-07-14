const boom = require("boom")
const bodyParser = require("body-parser")
const dateformat = require("dateformat")
const express = require("express")
const fs = require("fs")
const jwt = require("jsonwebtoken")
const request = require("request")
const uuidv4 = require("uuid/v4")

/*
  This application bridges the iOS app and the DeviceCheck API.
  Please refer to the following article about the specification of the DeviceCheck API.

  Accessing and Modifying Per-Device Data
  https://developer.apple.com/documentation/devicecheck/accessing_and_modifying_per-device_data
 */

// App Config

/* The base URL for testing environment.
   To transition to a production environment, you must use https://api.devicecheck.apple.com. */
const baseURL = "https://api.development.devicecheck.apple.com"

/* A 10-character Team ID, obtained from your developer account (https://developer.apple.com/account/) */
const teamID = "YOURTEAMID"

/* A 10-character key identifier, obtained from your developer account (https://developer.apple.com/account/) */
const keyIdentifier = "YOURKEYID"

/* A file name of p8 format private key download from Certificates, Identifiers & Profiles (https://developer.apple.com/account/ios/certificate) */
const keyFileName = "AuthKey.p8"


// Global objects

const app = express()
const cert = fs.readFileSync(keyFileName).toString()

// Express config

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

// Routes

app.get("/query", function(req, res, next) {
  var deviceToekn = req.query.deviceToken

  if (!deviceToekn) {
    throw boom.badRequest("deviceToken can't be blank")
  }

  var JWT = jwt.sign({}, cert, { algorithm: "ES256", keyid: keyIdentifier, issuer: teamID })

  // Send a query request
  request({
    method: "POST",
    url: baseURL + "/v1/query_two_bits",
    json: {
      "device_token" : deviceToekn,
      "transaction_id": uuidv4(),
      "timestamp": Date.now()
    },
    headers: {
      "Authorization": "Bearer " + JWT
    }
  }, function(error, response, json) {
    if (error) {
      return next(error)
    }
    if (response.statusCode != 200) {
      return next(new Error(response.body))
    }

    // Convert bits to counter
    var bitCounter = 0
    if (typeof json.bit0 == "undefined" && typeof json.bit1 == "undefined") {
      bitCounter = -1
    } else {
      if (!json.bit0 && !json.bit1) {
        bitCounter = 0
      } else if (json.bit0 && !json.bit1) {
        bitCounter = 1
      } else if (!json.bit0 && json.bit1) {
        bitCounter = 2
      } else {
        bitCounter = 3
      }
    }

    res.send({
       "counter": bitCounter,
       "lastUpdateTime": json.last_update_time 
    })
  })
})

app.post("/update", function(req, res, next) {
  var deviceToekn = req.body.deviceToken
  var bitCounter = req.body.counter

  if (!deviceToekn) {
    throw boom.badRequest("deviceToken can't be blank")
  }
  if (typeof bitCounter == "undefined") {
    throw boom.badRequest("bitCounter can't be blank")
  }
  if (bitCounter < 0 || 3 < bitCounter) {
    throw boom.badRequest("bitCounter must be between 0 and 3.")
  }

  // Convert coutner to bits
  var bit0 = false
  var bit1 = false
  if (bitCounter == 1) {
    bit0 = true
  } else if (bitCounter == 2) {
    bit1 = true
  } else if (bitCounter == 3) {
    bit0 = true
    bit1 = true
  }

  var JWT = jwt.sign({}, cert, { algorithm: "ES256", keyid: keyIdentifier, issuer: teamID })

  // Send an update request 
  request({
    method: "POST",
    url: baseURL + "/v1/update_two_bits",
    json: {
      "device_token" : deviceToekn,
      "transaction_id": uuidv4(),
      "timestamp": Date.now(),
      "bit0": bit0,
      "bit1": bit1
    },
    headers: {
      "Authorization": "Bearer " + JWT
    }
  }, function(error, response, body) {
    if (error) {
      return next(error)
    }
    if (response.statusCode != 200) {
      return next(new Error(response.body))
    }

    res.send({
      "counter": bitCounter,
      "lastUpdateTime": dateformat(new Date(), "yyyy-mm")
    })
  })
})

app.post("/validate", function(req, res, next) {
  var deviceToekn = req.body.deviceToken

  if (!deviceToekn) {
    throw boom.badRequest("deviceToken can't be blank")
  }

  var JWT = jwt.sign({}, cert, { algorithm: "ES256", keyid: keyIdentifier, issuer: teamID })

  // Send a query request
  request({
    method: "POST",
    url: baseURL + "/v1/validate_device_token",
    json: {
      "device_token" : deviceToekn,
      "transaction_id": uuidv4(),
      "timestamp": Date.now()
    },
    headers: {
      "Authorization": "Bearer " + JWT
    }
  }, function(error, response, json) {
    if (error) {
      return next(error)
    }
    if (response.statusCode != 200) {
      return next(new Error(response.body))
    }

    res.status(response.statusCode)
    res.send(response.message)
  })
})

// Error handlers

app.use(function(err, req, res, next) {
  if (!err.isBoom) {
     return next(err)
  }

  console.error(err.stack)

  if (err.isServer) {
    return
  }

  res.status(err.output.statusCode)
  res.send(err.output.payload.message)
})

app.use(function(err, req, res, next) {
  if (res.headersSent) {
    return next(err)
  }

  console.error(err.stack)

  res.status(500)
  res.send(err.message)
})

// Start server

var server = app.listen(3000, function() {
	console.log("Listening on port " + server.address().port)
})
