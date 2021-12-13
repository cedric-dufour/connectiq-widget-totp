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

using Toybox.Cryptography as Crypto;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerAccountEditTX extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get value
    var iValue = $.dictMyCurrentTotpAccount != null ? $.dictMyCurrentTotpAccount["TX"] : 30;
    if(iValue < 10) {
      iValue = 10;
    }
    else if(iValue > 600) {
      iValue = 600;
    }

    // Initialize picker
    var oFactory = new PickerFactoryNumber(10, 600, null);
    Picker.initialize({
        :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleAccountTX), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
        :pattern => [ oFactory ],
        :defaults => [ oFactory.indexOf(iValue) ]
    });
  }

}

class PickerAccountEditTXDelegate extends Ui.PickerDelegate {

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
      dictAccount["TX"] = _amValues[0];
    }
    else {
      dictAccount = { "ID" => Ui.loadResource(Rez.Strings.valueAccountNameNew), "K" => "", "E" => MyAlgorithms.ENCODING_BASE32, "D" => 6, "H" => Crypto.HASH_SHA1, "T0" => 0l, "TX" => _amValues[0] };
    }

    // Set account and exit
    $.dictMyCurrentTotpAccount = dictAccount;
    $.arrMyCurrentTotpCode = null;
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
