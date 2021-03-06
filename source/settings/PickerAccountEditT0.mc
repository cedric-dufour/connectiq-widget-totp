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

class PickerAccountEditT0 extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get value
    var lValue = $.TOTP_dictCurrentAccount != null ? $.TOTP_dictCurrentAccount["T0"] : 0;
    if(lValue < 0l) {
      lValue = 0l;
    }
    else if(lValue > 100000000000l) {
      lValue = 100000000000l;
    }

    // Split components
    var amValues = new [4];
    amValues[3] = (lValue % 1000).toNumber();
    lValue = lValue / 1000l;
    amValues[2] = (lValue % 1000).toNumber();
    lValue = lValue / 1000l;
    amValues[1] = (lValue % 1000).toNumber();
    lValue = lValue / 1000l;
    amValues[0] = lValue.toNumber();
    
    // Initialize picker
    Picker.initialize({
        :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleAccountT0), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
        :pattern => [ new PickerFactoryNumber(0, 100, { :langFormat => "$1$'" }),
                      new PickerFactoryNumber(0, 999, { :langFormat => "$1$'", :format => "%03d" }),
                      new PickerFactoryNumber(0, 999, { :langFormat => "$1$'", :format => "%03d" }),
                      new PickerFactoryNumber(0, 999, { :format => "%03d" }) ],
        :defaults => amValues
    });
  }

}

class PickerAccountEditT0Delegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var lValue = _amValues[0]*1000000000l + _amValues[1]*1000000l + _amValues[2]*1000l + _amValues[3];
    
    // Update/create account (dictionary)
    var dictAccount = $.TOTP_dictCurrentAccount;
    if(dictAccount != null) {
      dictAccount["T0"] = lValue;
    }
    else {
      dictAccount = { "ID" => Ui.loadResource(Rez.Strings.valueAccountNameNew), "K" => "", "E" => TOTP_Algorithms.ENCODING_BASE32, "D" => 6, "H" => Crypto.HASH_SHA1, "T0" => lValue, "T0" => 30 };
    }

    // Set account and exit
    $.TOTP_dictCurrentAccount = dictAccount;
    $.TOTP_arrCurrentCode = null;
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
