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

import Toybox.Lang;
using Toybox.Cryptography as Crypto;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerAccountEditName extends Ui.TextPicker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Initialize picker
    TextPicker.initialize($.dictMyCurrentTotpAccount != null
                          ? ($.dictMyCurrentTotpAccount as Dictionary<String>)["ID"] as String
                          : "");
  }

}

class PickerAccountEditNameDelegate extends Ui.TextPickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    TextPickerDelegate.initialize();
  }

  function onTextEntered(_sText, _bChanged) {
    // Update/create account (dictionary)
    var dictAccount = $.dictMyCurrentTotpAccount;
    if(dictAccount != null) {
      dictAccount["ID"] = _sText;
    }
    else {
      dictAccount = {
        "ID" => _sText,
        "K" => "",
        "E" => MyAlgorithms.ENCODING_BASE32,
        "D" => 6,
        "H" => Crypto.HASH_SHA1,
        "T0" => 0l,
        "TX" => 30
      } as Dictionary<String>?;
    }

    // Set account and exit
    $.dictMyCurrentTotpAccount = dictAccount;
    return true;
  }

  function onCancel() {
    // Exit
    return true;
  }

}
