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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuAccountsEdit extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsAccount) as String);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountName) as String, :menuAccountName);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountKey) as String, :menuAccountKey);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountKey2) as String, :menuAccountKey2);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountEncoding) as String, :menuAccountEncoding);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountDigits) as String, :menuAccountDigits);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountHash) as String, :menuAccountHash);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountT0) as String, :menuAccountT0);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountTX) as String, :menuAccountTX);
  }
}

class MenuAccountsEditDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuAccountName) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountName)");
      Ui.pushView(new PickerAccountEditName(),
                  new PickerAccountEditNameDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountKey) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountKey)");
      Ui.pushView(new PickerAccountEditKey(),
                  new PickerAccountEditKeyDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountKey2) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountKey2)");
      Ui.pushView(new PickerAccountEditKey2(),
                  new PickerAccountEditKey2Delegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountEncoding) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountEncoding)");
      Ui.pushView(new PickerAccountEditEncoding(),
                  new PickerAccountEditEncodingDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountDigits) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountDigits)");
      Ui.pushView(new PickerAccountEditDigits(),
                  new PickerAccountEditDigitsDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountHash) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountHash)");
      Ui.pushView(new PickerAccountEditHash(),
                  new PickerAccountEditHashDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountT0) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountT0)");
      Ui.pushView(new PickerAccountEditT0(),
                  new PickerAccountEditT0Delegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountTX) {
      //Sys.println("DEBUG: MenuAccountEditDelegate.onMenuItem(:menuAccountTX)");
      Ui.pushView(new PickerAccountEditTX(),
                  new PickerAccountEditTXDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
  }

}
