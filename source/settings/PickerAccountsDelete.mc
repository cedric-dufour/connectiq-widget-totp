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

class PickerAccountsDelete extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Accounts memory
    var aiMemoryKeys = new Array<Number>[$.MY_STORAGE_SLOTS];
    var asMemoryValues = new Array<String>[$.MY_STORAGE_SLOTS];
    var iMemoryUsed = 0;
    for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      var dictAccount = App.Storage.getValue(format("ACT$1$", [s])) as Dictionary<String>?;
      if(dictAccount != null) {
        aiMemoryKeys[iMemoryUsed] = n;
        asMemoryValues[iMemoryUsed] = format("[$1$]\n$2$", [s, dictAccount["ID"]]);
        iMemoryUsed++;
      }
    }

    // Initialize picker
    var oPattern;
    if(iMemoryUsed > 0) {
      aiMemoryKeys = aiMemoryKeys.slice(0, iMemoryUsed);
      asMemoryValues = asMemoryValues.slice(0, iMemoryUsed);
      oPattern = new PickerFactoryDictionary(aiMemoryKeys, asMemoryValues, {:font => Gfx.FONT_TINY});
    }
    else {
      oPattern = new PickerFactoryDictionary([null], ["-"], {:color => Gfx.COLOR_DK_GRAY});
    }
    Picker.initialize({
        :title => new Ui.Text({
            :text => Ui.loadResource(Rez.Strings.titleAccountsDelete) as String,
            :font => Gfx.FONT_TINY,
            :locX=>Ui.LAYOUT_HALIGN_CENTER,
            :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
            :color => Gfx.COLOR_BLUE}),
        :pattern => [oPattern]});
  }

}

class PickerAccountsDeleteDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Delete account
    if(_amValues[0] != null) {
      var s = (_amValues[0] as Number).format("%02d");
      App.Storage.deleteValue(format("ACT$1$", [s]));
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
