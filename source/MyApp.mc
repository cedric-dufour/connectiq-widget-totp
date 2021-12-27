// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// TOTP (Garmin ConnectIQ) Widget (TOTP)
// Copyright (C) 2018-2021 Cedric Dufour <http://cedric.dufour.name>
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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.Cryptography as Crypto;
using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Current account and code
var iMyCurrentTotpAccount as Number?;
var dictMyCurrentTotpAccount as Dictionary<String>?;
var arrMyCurrentTotpCode as Array?;

// Current view
var oMyView as MyView?;


//
// CONSTANTS
//

// Storage slots
const MY_STORAGE_SLOTS = 100;


//
// CLASS
//

(:glance)
class MyApp extends App.AppBase {

  //
  // VARIABLES
  //

  // UI update time
  private var oUpdateTimer as Timer.Timer?;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    //Sys.println("DEBUG: MyApp.onStart()");

    // DEBUG
    // var dictAccount;
    // // oathtool --totp=sha1 --digits=6 --base32 5B5E7MMX344QRHYO
    // dictAccount = {
    //   "ID" => "Google",
    //   "K" => "5B5E7MMX344QRHYO",
    //   "E" => MyAlgorithms.ENCODING_BASE32,
    //   "D" => 6,
    //   "H" => Crypto.HASH_SHA1,
    //   "T0" => 0l,
    //   "TX" => 30
    // } as Dictionary<String>?;
    // App.Storage.setValue("ACT99", dictAccount as App.PropertyValueType);
    // // oathtool --totp=sha1 --digits=8 3132333435363738393031323334353637383930
    // dictAccount = {
    //   "ID" => "SHA1",
    //    "K" => "3132333435363738393031323334353637383930",
    //    "E" => MyAlgorithms.ENCODING_HEX,
    //    "D" => 8,
    //    "H" => Crypto.HASH_SHA1,
    //    "T0" => 0l,
    //    "TX" => 30
    // } as Dictionary<String>?;
    // App.Storage.setValue("ACT98", dictAccount as App.PropertyValueType);
    // // oathtool --totp=sha256 --digits=8 3132333435363738393031323334353637383930313233343536373839303132
    // dictAccount = {
    //   "ID" => "SHA256",
    //   "K" => "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA",
    //   "E" => MyAlgorithms.ENCODING_BASE32,
    //   "D" => 8,
    //   "H" => Crypto.HASH_SHA256,
    //   "T0" => 0l,
    //   "TX" => 30
    // } as Dictionary<String>?;
    // App.Storage.setValue("ACT97", dictAccount as App.PropertyValueType);
  }

  function onStop(state) {
    //Sys.println("DEBUG: MyApp.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
      self.oUpdateTimer = null;
    }
  }

  function getInitialView() {
    //Sys.println("DEBUG: MyApp.getInitialView()");

    return [new MyView(), new MyViewDelegate()] as Array<Ui.Views or Ui.InputDelegates>;
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: MyApp.onSettingsChanged()");

    // Import account
    if ((App.Properties.getValue("importAccountName") as String).length() > 0
        and (App.Properties.getValue("importAccountKey") as String).length() > 0) {
      // ... store account
      var dictAccount = {
        "ID" => App.Properties.getValue("importAccountName") as String,
        "K" => App.Properties.getValue("importAccountKey") as String,
        "E" => (App.Properties.getValue("importAccountEncoding") as Number).toNumber(),
        "D" => (App.Properties.getValue("importAccountDigits") as Number).toNumber(),
        "H" => (App.Properties.getValue("importAccountHash") as Number).toNumber(),
        "T0" => (App.Properties.getValue("importAccountT0") as Number or Long).toLong(),
        "TX" => (App.Properties.getValue("importAccountTX") as Number).toNumber()
      };
      var s = (App.Properties.getValue("importAccountSlot") as Number).format("%02d");
      App.Storage.setValue(format("ACT$1$", [s]), dictAccount as App.PropertyValueType);

      // ... reset import properties/settings
      App.Properties.setValue("importAccountSlot", 0 as App.PropertyValueType);
      App.Properties.setValue("importAccountName", "" as App.PropertyValueType);
      App.Properties.setValue("importAccountKey", "" as App.PropertyValueType);
    }
  }


  //
  // FUNCTIONS: self
  //

  function updateApp() as Void {
    //Sys.println("DEBUG: MyApp.updateApp()");

    // Update UI
    self.updateUi();
  }

  function updateUi() as Void {
    //Sys.println("DEBUG: MyApp.updateUi()");

    // Update UI
    if($.oMyView != null) {
        ($.oMyView as MyView).updateUi();
    }
  }

  function startTimer() as Void {
    //Sys.println("DEBUG: MyApp.startTimer()");

    // (Re-)Start the compute timer (delay 1 second)
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
    }
    self.oUpdateTimer = new Timer.Timer();
    (self.oUpdateTimer as Timer.Timer).start(method(:onComputeTimer), 1000, false);
  }

  function onComputeTimer() as Void {
    //Sys.println("DEBUG: MyApp.onComputeTimer()");

    // Compute TOTP code
    if($.arrMyCurrentTotpCode == null) {
      self.computeTOTP();
    }

    // Update UI
    self.updateUi();

    // Start the UI update timer (every 1 second)
    self.oUpdateTimer = new Timer.Timer();
    (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 1000, true);
  }

  function onUpdateTimer() as Void {
    //Sys.println("DEBUG: MyApp.onUpdateTimer()");
    self.updateUi();
  }

  function stopTimer() as Void {
    //Sys.println("DEBUG: MyApp.stopTimer()");

    // Stop timer
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
    }
    self.oUpdateTimer = null;
  }

  function computeTOTP() as Void {
    //Sys.println("DEBUG: MyApp.computeTOTP()");

    // Compute TOTP code
    if($.dictMyCurrentTotpAccount != null) {
      var iNow = Time.now().value();
      var dictAccount = $.dictMyCurrentTotpAccount as Dictionary<String>;

      // ... counter
      var amCounter = MyAlgorithms.TOTP_Counter(iNow.toLong(),
                                                dictAccount["T0"] as Long,
                                                dictAccount["TX"] as Number);

      // ... code
      var baK = MyAlgorithms.ByteArray_fromEncoding(dictAccount["K"] as String,
                                                    dictAccount["E"] as Number);
      $.arrMyCurrentTotpCode = [MyAlgorithms.HOTP_Code(dictAccount["D"] as Number,
                                                       baK,
                                                       amCounter[0] as ByteArray,
                                                       dictAccount["H"] as Number),
                                iNow + amCounter[2] - (dictAccount["TX"] as Number),
                                iNow + amCounter[2]];
    }
  }

}
