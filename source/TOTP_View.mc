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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//
// CLASS
//

class TOTP_View extends Ui.View {

  //
  // CONSTANTS
  //

  private const NOVALUE_BLANK = "";
  private const NOVALUE_LEN3 = "---";
  private const NOVALUE_PENDING = "...";


  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode (internal)
    self.bShow = false;
  }

  function onLayout(_oDC) {
    // No layout; see drawLayout() below
  }

  function onShow() {
    //Sys.println("DEBUG: TOTP_View.onShow()");

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Done
    self.bShow = true;
    $.TOTP_oCurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: TOTP_View.onUpdate()");

    // Update layout
    View.onUpdate(_oDC);
    self.drawLayout(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: TOTP_View.onHide()");
    App.getApp().stopTimer();
    $.TOTP_oCurrentView = null;
    self.bShow = false;
  }


  //
  // FUNCTIONS: self
  //

  function reloadSettings() {
    //Sys.println("DEBUG: TOTP_View.reloadSettings()");

    // Schedule pending computation
    if($.TOTP_dictCurrentAccount != null) {
      App.getApp().startTimer();
    }

    // Update application state
    App.getApp().updateApp();
  }

  function updateUi() {
    //Sys.println("DEBUG: TOTP_View.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function drawLayout(_oDC) {
    //Sys.println("DEBUG: TOTP_View.drawLayout()");
    var iNow = Time.now().value();
    //Sys.println(Lang.format("DEBUG: Now = $1$", [iNow]));
    
    // Draw background
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    // Data
    if($.TOTP_arrCurrentCode != null and iNow >= $.TOTP_arrCurrentCode[2]) {
      // ... re-compute expired TOTP code
      App.getApp().computeTOTP();
    }

    // Draw
    var sValue;
    var iX = _oDC.getWidth()/2;
    var iY = _oDC.getHeight()/2;
    iY -= _oDC.getFontHeight(Gfx.FONT_MEDIUM)*1.2f + _oDC.getFontHeight(Gfx.FONT_NUMBER_MEDIUM)/2;

    // ... account
    if($.TOTP_dictCurrentAccount != null) {
      sValue = $.TOTP_dictCurrentAccount["ID"];
    }
    else {
      sValue = Ui.loadResource(Rez.Strings.labelAccountSelect);
    }
    _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
    _oDC.drawText(iX, iY, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    iY += _oDC.getFontHeight(Gfx.FONT_MEDIUM)*1.2f;

    // ... TOTP
    if($.TOTP_arrCurrentCode != null) {
      sValue = $.TOTP_arrCurrentCode[0];
    }
    else if($.TOTP_dictCurrentAccount != null) {
      sValue = self.NOVALUE_PENDING;
    }
    else {
      sValue = self.NOVALUE_LEN3;
    }
    _oDC.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    _oDC.drawText(iX, iY, Gfx.FONT_NUMBER_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    iY += _oDC.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) + _oDC.getFontHeight(Gfx.FONT_MEDIUM)*0.5f;

    // ... time (remaining)
    if($.TOTP_arrCurrentCode != null) {
      //Sys.println(Lang.format("DEBUG: Code = $1$", [$.TOTP_arrCurrentCode]));
      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
      _oDC.setPenWidth(1);
      _oDC.drawRectangle(iX/2-3, iY-3, iX+6, 6);
      
      var fValidity = (iNow - $.TOTP_arrCurrentCode[1]).toFloat()/($.TOTP_arrCurrentCode[2] - $.TOTP_arrCurrentCode[1]).toFloat();
      //Sys.println(Lang.format("DEBUG: Validity = $1$", [fValidity]));
      _oDC.setPenWidth(4);
      _oDC.drawLine(iX/2, iY, iX/2+iX*fValidity, iY);
    }

  }

}

class TOTP_ViewDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: TOTP_ViewDelegate.onMenu()");
    Ui.pushView(new MenuSettings(), new MenuSettingsDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: TOTP_ViewDelegate.onSelect()");

    // Stop and reset any (pending) computation
    App.getApp().stopTimer();
    $.TOTP_arrCurrentCode = null;

    // Select next available account
    $.TOTP_dictCurrentAccount = null;
    var i = $.TOTP_iCurrentAccount != null ? $.TOTP_iCurrentAccount+1 : 0;
    for(var n=0; n<$.TOTP_STORAGE_SLOTS; n++) {
      var s = i.format("%02d");
      var dictAccount = App.Storage.getValue("ACT"+s);
      if(dictAccount != null) {
        $.TOTP_iCurrentAccount = i;
        $.TOTP_dictCurrentAccount = dictAccount;
        App.getApp().startTimer();
        break;
      }
      i = (i + 1) % $.TOTP_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

}
