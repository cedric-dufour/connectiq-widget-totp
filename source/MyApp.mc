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
var iMyCurrentTotpAccount = null;
var dictMyCurrentTotpAccount = null;
var arrMyCurrentTotpCode = null;

// Current view
var oMyView = null;


//
// CONSTANTS
//

// Storage slots
const MY_STORAGE_SLOTS = 100;


//
// CLASS
//

class MyApp extends App.AppBase {

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
    //Sys.println("DEBUG: MyApp.onStart()");

    // DEBUG
    // // oathtool --totp=sha1 --digits=6 --base32 5B5E7MMX344QRHYO
    // App.Storage.setValue("ACT99",
    //                      { "ID" => "Google",
    //                          "K" => "5B5E7MMX344QRHYO",
    //                          "E" => MyAlgorithms.ENCODING_BASE32,
    //                          "D" => 6,
    //                          "H" => Crypto.HASH_SHA1,
    //                          "T0" => 0l,
    //                          "TX" => 30 });
    // // oathtool --totp=sha1 --digits=8 3132333435363738393031323334353637383930
    // App.Storage.setValue("ACT98",
    //                      { "ID" => "SHA1",
    //                          "K" => "3132333435363738393031323334353637383930",
    //                          "E" => MyAlgorithms.ENCODING_HEX,
    //                          "D" => 8,
    //                          "H" => Crypto.HASH_SHA1,
    //                          "T0" => 0l,
    //                          "TX" => 30 });
    // // oathtool --totp=sha256 --digits=8 3132333435363738393031323334353637383930313233343536373839303132
    // App.Storage.setValue("ACT97",
    //                      { "ID" => "SHA256",
    //                          "K" => "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA",
    //                          "E" => MyAlgorithms.ENCODING_BASE32,
    //                          "D" => 8,
    //                          "H" => Crypto.HASH_SHA256,
    //                          "T0" => 0l,
    //                          "TX" => 30 } );
  }

  function onStop(state) {
    //Sys.println("DEBUG: MyApp.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
      self.oUpdateTimer = null;
    }
  }

  function getInitialView() {
    //Sys.println("DEBUG: MyApp.getInitialView()");

    return [new MyView(), new MyViewDelegate()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: MyApp.onSettingsChanged()");

    // Import account
    if (App.Properties.getValue("importAccountName").length() > 0 and App.Properties.getValue("importAccountKey").length() > 0) {
      // ... store account
      var dictAccount = {
        "ID" => App.Properties.getValue("importAccountName"),
        "K" => App.Properties.getValue("importAccountKey"),
        "E" => App.Properties.getValue("importAccountEncoding").toNumber(),
        "D" => App.Properties.getValue("importAccountDigits").toNumber(),
        "H" => App.Properties.getValue("importAccountHash").toNumber(),
        "T0" => App.Properties.getValue("importAccountT0").toLong(),
        "TX" => App.Properties.getValue("importAccountTX").toNumber()
      };
      var s = App.Properties.getValue("importAccountSlot").format("%02d");
      App.Storage.setValue(Lang.format("ACT$1$", [s]), dictAccount);

      // ... reset import properties/settings
      App.Properties.setValue("importAccountSlot", 0);
      App.Properties.setValue("importAccountName", "");
      App.Properties.setValue("importAccountKey", "");
    }
  }


  //
  // FUNCTIONS: self
  //

  function updateApp() {
    //Sys.println("DEBUG: MyApp.updateApp()");

    // Update UI
    self.updateUi();
  }

  function updateUi() {
    //Sys.println("DEBUG: MyApp.updateUi()");

    // Update UI
    if($.oMyView != null) {
      $.oMyView.updateUi();
    }
  }

  function startTimer() {
    //Sys.println("DEBUG: MyApp.startTimer()");

    // (Re-)Start the compute timer (delay 1 second)
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
    }
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onComputeTimer), 1000, false);
  }

  function onComputeTimer() {
    //Sys.println("DEBUG: MyApp.onComputeTimer()");

    // Compute TOTP code
    if($.arrMyCurrentTotpCode == null) {
      self.computeTOTP();
    }

    // Update UI
    self.updateUi();

    // Start the UI update timer (every 1 second)
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 1000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: MyApp.onUpdateTimer()");
    self.updateUi();
  }

  function stopTimer() {
    //Sys.println("DEBUG: MyApp.stopTimer()");

    // Stop timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
    }
    self.oUpdateTimer = null;
  }

  function computeTOTP() {
    //Sys.println("DEBUG: MyApp.computeTOTP()");

    // Compute TOTP code
    if($.dictMyCurrentTotpAccount != null) {
      var iNow = Time.now().value();

      // ... counter
      var amCounter = MyAlgorithms.TOTP_Counter(iNow, $.dictMyCurrentTotpAccount["T0"], $.dictMyCurrentTotpAccount["TX"]);

      // ... code
      var baK = MyAlgorithms.ByteArray_fromEncoding($.dictMyCurrentTotpAccount["K"], $.dictMyCurrentTotpAccount["E"]);
      $.arrMyCurrentTotpCode = [ MyAlgorithms.HOTP_Code($.dictMyCurrentTotpAccount["D"], baK, amCounter[0], $.dictMyCurrentTotpAccount["H"]),
                                iNow + amCounter[2] - $.dictMyCurrentTotpAccount["TX"],
                                iNow + amCounter[2] ];
    }
  }

}
