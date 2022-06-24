// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// TOTP (Garmin ConnectIQ) Widget (TOTP)
// Copyright (C) 2018-2022 Cedric Dufour <http://cedric.dufour.name>
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

class PickerAccountEditHash extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get value
    var iValue =
      $.dictMyCurrentTotpAccount != null
      ? ($.dictMyCurrentTotpAccount as Dictionary<String>)["H"] as Number
      : Crypto.HASH_SHA1;

    // Initialize picker
    var oFactory = new PickerFactoryDictionary([Crypto.HASH_SHA1, Crypto.HASH_SHA256],
                                               [Ui.loadResource(Rez.Strings.valueAccountHashSHA1), Ui.loadResource(Rez.Strings.valueAccountHashSHA256)],
                                               {:font => Gfx.FONT_TINY});
    var iIndex = oFactory.indexOfKey(iValue);
    Picker.initialize({
        :title => new Ui.Text({
            :text => Ui.loadResource(Rez.Strings.titleAccountHash) as String,
            :font => Gfx.FONT_TINY,
            :locX=>Ui.LAYOUT_HALIGN_CENTER,
            :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
            :color => Gfx.COLOR_BLUE}),
        :pattern => [oFactory],
        :defaults => [iIndex >= 0 ? iIndex : Crypto.HASH_SHA1]});
  }

}

class PickerAccountEditHashDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Update/create account (dictionary)
    var dictAccount = $.dictMyCurrentTotpAccount;
    if(dictAccount != null) {
      dictAccount["H"] = _amValues[0] as Number;
    }
    else {
      dictAccount = {
        "ID" => Ui.loadResource(Rez.Strings.valueAccountNameNew) as String,
        "K" => "",
        "E" => MyAlgorithms.ENCODING_BASE32,
        "D" => 6,
        "H" => _amValues[0] as Number,
        "T0" => 0l,
        "TX" => 30
      } as Dictionary<String>?;
    }

    // Set account and exit
    $.dictMyCurrentTotpAccount = dictAccount;
    $.arrMyCurrentTotpCode = null;
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
