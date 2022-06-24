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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuSettingsAccounts extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsAccounts) as String);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountsNew) as String, :menuAccountsNew);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountsEdit) as String, :menuAccountsEdit);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountsSave) as String, :menuAccountsSave);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountsLoad) as String, :menuAccountsLoad);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAccountsDelete) as String, :menuAccountsDelete);
  }

}

class MenuSettingsAccountsDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuAccountsNew) {
      //Sys.println("DEBUG: MenuSettingsAccountsDelegate.onMenuItem(:menuAccountsNew)");
      $.dictMyCurrentTotpAccount = null;
      $.arrMyCurrentTotpCode = null;
      Ui.pushView(new MenuAccountsEdit(),
                  new MenuAccountsEditDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountsEdit) {
      //Sys.println("DEBUG: MenuSettingsAccountsDelegate.onMenuItem(:menuAccountsEdit)");
      Ui.pushView(new MenuAccountsEdit(),
                  new MenuAccountsEditDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountsSave) {
      //Sys.println("DEBUG: MenuSettingsAccountsDelegate.onMenuItem(:menuAccountsSave)");
      Ui.pushView(new PickerAccountsSave(),
                  new PickerAccountsSaveDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountsLoad) {
      //Sys.println("DEBUG: MenuSettingsAccountsDelegate.onMenuItem(:menuAccountsLoad)");
      Ui.pushView(new PickerAccountsLoad(),
                  new PickerAccountsLoadDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAccountsDelete) {
      //Sys.println("DEBUG: MenuSettingsAccountsDelegate.onMenuItem(:menuAccountsDelete)");
      Ui.pushView(new PickerAccountsDelete(),
                  new PickerAccountsDeleteDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }
  }

}
