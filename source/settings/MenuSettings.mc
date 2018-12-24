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

using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuSettings extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettings));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsAccounts), :menuSettingsAccounts);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsAbout), :menuSettingsAbout);
  }

}

class MenuSettingsDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuSettingsAccounts) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsAccounts)");
      Ui.pushView(new MenuSettingsAccounts(), new MenuSettingsAccountsDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsAbout) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsAbout)");
      Ui.pushView(new MenuSettingsAbout(), new MenuSettingsAboutDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
