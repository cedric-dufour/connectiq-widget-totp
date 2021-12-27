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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerAccountsSave extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Accounts memory
    var aiMemoryKeys = new Array<Number>[$.MY_STORAGE_SLOTS];
    var asMemoryValues = new Array<String>[$.MY_STORAGE_SLOTS];
    for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
      aiMemoryKeys[n] = n;
      var s = n.format("%02d");
      var dictAccount = App.Storage.getValue(format("ACT$1$", [s])) as Dictionary<String>?;
      if(dictAccount != null) {
        asMemoryValues[n] = format("[$1$]\n$2$", [s, dictAccount["ID"]]);
      }
      else {
        asMemoryValues[n] = format("[$1$]\n----", [s]);
      }
    }

    // Initialize picker
    Picker.initialize({
      :title => new Ui.Text({
          :text => Ui.loadResource(Rez.Strings.titleAccountsSave) as String,
          :font => Gfx.FONT_TINY,
          :locX=>Ui.LAYOUT_HALIGN_CENTER,
          :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
          :color => Gfx.COLOR_BLUE}),
      :pattern => [new PickerFactoryDictionary(aiMemoryKeys, asMemoryValues, {:font => Gfx.FONT_TINY})]});
  }

}

class PickerAccountsSaveDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Save account
    var dictAccount = $.dictMyCurrentTotpAccount;
    if(dictAccount != null) {
      // WARNING: We MUST store a new (different) dictionary instance (deep copy)!
      var s = (_amValues[0] as Number).format("%02d");
      App.Storage.setValue(format("ACT$1$", [s]), LangUtils.copy(dictAccount as Object) as App.PropertyValueType);
    }

    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
