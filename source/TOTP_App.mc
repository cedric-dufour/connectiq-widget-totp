// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// TOTP (Garmin ConnectIQ) Widget (TOTP)
// Copyright (C) 2018 Cedric Dufour <http://cedric.dufour.name>
//
// TOTP (Garmin ConnectIQ) Widget (TOTP) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// TOTP (Garmin ConnectIQ) Widget (TOTP) is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Application as App;
using Toybox.Cryptography as Crypto;
using Toybox.System as Sys;
using Toybox.Timer;

//
// GLOBALS
//

// Current account and code
var TOTP_iCurrentAccount = null;
var TOTP_dictCurrentAccount = null;
var TOTP_arrCurrentCode = null;

// Current view
var TOTP_oCurrentView = null;


//
// CONSTANTS
//

// Storage slots
const TOTP_STORAGE_SLOTS = 100;


//
// CLASS
//

class TOTP_App extends App.AppBase {

  //
  // VARIABLES
  //

  // UI update time
  private var oUpdateTimer;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

    // UI update time
    self.oUpdateTimer = null;
  }

  function onStart(state) {
    //Sys.println("DEBUG: TOTP_App.onStart()");

    // DEBUG
    // // oathtool --totp=sha1 --digits=6 --base32 5B5E7MMX344QRHYO
    // App.Storage.setValue("ACT99",
    //                      { "ID" => "Google",
    //                          "K" => "5B5E7MMX344QRHYO",
    //                          "E" => TOTP_Algorithms.ENCODING_BASE32,
    //                          "D" => 6,
    //                          "H" => Crypto.HASH_SHA1,
    //                          "T0" => 0l,
    //                          "TX" => 30 });
    // // oathtool --totp=sha1 --digits=8 3132333435363738393031323334353637383930
    // App.Storage.setValue("ACT98",
    //                      { "ID" => "SHA1",
    //                          "K" => "3132333435363738393031323334353637383930",
    //                          "E" => TOTP_Algorithms.ENCODING_HEX,
    //                          "D" => 8,
    //                          "H" => Crypto.HASH_SHA1,
    //                          "T0" => 0l,
    //                          "TX" => 30 });
    // // oathtool --totp=sha256 --digits=8 3132333435363738393031323334353637383930313233343536373839303132
    // App.Storage.setValue("ACT97",
    //                      { "ID" => "SHA256",
    //                          "K" => "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA",
    //                          "E" => TOTP_Algorithms.ENCODING_BASE32,
    //                          "D" => 8,
    //                          "H" => Crypto.HASH_SHA256,
    //                          "T0" => 0l,
    //                          "TX" => 30 } );
  }

  function onStop(state) {
    //Sys.println("DEBUG: TOTP_App.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
      self.oUpdateTimer = null;
    }
  }

  function getInitialView() {
    //Sys.println("DEBUG: TOTP_App.getInitialView()");

    return [new TOTP_View(), new TOTP_ViewDelegate()];
  }


  //
  // FUNCTIONS: self
  //

  function updateApp() {
    //Sys.println("DEBUG: TOTP_App.updateApp()");

    // Update UI
    self.updateUi();
  }

  function updateUi() {
    //Sys.println("DEBUG: TOTP_App.updateUi()");

    // Update UI
    if($.TOTP_oCurrentView != null) {
      $.TOTP_oCurrentView.updateUi();
    }
  }

  function startTimer() {
    //Sys.println("DEBUG: TOTP_App.startTimer()");

    // Start compute timer (delay 1 second)
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
    }
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onComputeTimer), 1000, false);
  }

  function onComputeTimer() {
    //Sys.println("DEBUG: PH_App.onComputeTimer()");

    // Compute TOTP code
    if($.TOTP_arrCurrentCode == null) {
      self.computeTOTP();
    }

    // Update UI
    self.updateUi();

    // Start UI update timer (every 1 second)
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 1000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: PH_App.onUpdateTimer()");
    self.updateUi();
  }
  
  function stopTimer() {
    //Sys.println("DEBUG: TOTP_App.stopTimer()");

    // Stop timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
    }
    self.oUpdateTimer = null;
  }

  function computeTOTP() {
    //Sys.println("DEBUG: PH_App.computeTOTP()");

    // Compute TOTP code
    if($.TOTP_dictCurrentAccount != null) {
      var iNow = Time.now().value();
      
      // ... counter
      var amCounter = TOTP_Algorithms.TOTP_Counter(iNow, $.TOTP_dictCurrentAccount["T0"], $.TOTP_dictCurrentAccount["TX"]);

      // ... code
      var baK = TOTP_Algorithms.ByteArray_fromEncoding($.TOTP_dictCurrentAccount["K"], $.TOTP_dictCurrentAccount["E"]);
      $.TOTP_arrCurrentCode = [ TOTP_Algorithms.HOTP_Code($.TOTP_dictCurrentAccount["D"], baK, amCounter[0], $.TOTP_dictCurrentAccount["H"]),
                                iNow + amCounter[2] - $.TOTP_dictCurrentAccount["TX"],
                                iNow + amCounter[2] ];
    }
  }

}
