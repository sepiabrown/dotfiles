# Instruction at the back!
#
{ config, pkgs, ... }:

{
  console.useXkbConfig = true; # apply this setting in outside of X11; configure the virtual console keymap from the xserver keyboard settings. 
  services = {
    xserver = { 
      # Configure keymap in X11
      # xkbModel = "pc105"; not used in extraLayouts
      # displayManager.sessionCommands = "setxkbmap -symbols \"us(dvorak)\" -option \"terminate:ctrl_alt_bksp\""; doesn't work
      displayManager.sessionCommands = 
        if config.services.xserver.displayManager.sddm.enable == true 
        then "setxkbmap -keycodes custom_apple" else "";
        # Disable plasma application menu popup: https://www.reddit.com/r/kde/comments/9uspp8/how_do_i_disable_the_plasma_application_menu_pop/  https://zren.github.io/kde/#windowsmeta-key
        # kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "" qdbus org.kde.KWin /KWin reconfigure
        # to enable meta to turn on application launcher in kde plasma, erase ~/.config/kwinrc to reset or put 'kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu" qdbus org.kde.KWin /KWin reconfigure' in the if statement instead.
      layout = "custom_apple";
      extraLayouts.custom_windows = # custom_windows: real xkb symbol file name
      let 
        custom_windows_config = pkgs.writeText "windows_custom_xkeyboard" # windows_custom_xkeyboard : patch file name
''
// '!!!' for changes made by sepiabrown
default partial alphanumeric_keys modifier_keys
xkb_symbols "basic" // !!!
{
    include "us(dvorak)" // !!!
    // key <ESC>  {	[ Escape		]	};
    key <ESC>  {	[ 		]	}; // !!!

    // The extra key on many European keyboards:
    key <LSGT> {	[ less, greater, bar, brokenbar ] };

    // The following keys are common to all layouts.
    key <BKSL> {	[ backslash,	bar	]	};
    key <SPCE> {	[ 	 space		]	};

    include "srvr_ctrl(fkey2vt)"
    include "pc(editing)"
    include "keypad(x11)"

    key <BKSP> {	[ BackSpace, BackSpace	]	};

    key  <TAB> {	[ Tab,	ISO_Left_Tab	]	};
    key <RTRN> {	[ Return		]	};

    //key <CAPS> {	[ Caps_Lock		]	};
    key <CAPS> {	[ Super_R		]	}; // !!!
    key <NMLK> {	[ Num_Lock 		]	};

    key <LFSH> {	[ Shift_L		]	};
    key <LCTL> {	[ Control_L		]	};
    // key <LWIN> {	[ Super_L		]	};
    key <LWIN> {	[ Caps_Lock		]	}; // !!!

    // key <RTSH> {	[ Shift_R		]	};
    key <RTSH> {	[ Escape		]	}; // !!!
    key <RCTL> {	[ Control_R		]	};
    // key <RWIN> {	[ Super_R		]	};
    key <RWIN> {	[ NoSymbol		]	}; // !!!
    key <MENU> {	[ Menu			]	};

    // Beginning of modifier mappings.
    modifier_map Shift  { Shift_L, Shift_R };
    modifier_map Lock   { Caps_Lock };
    modifier_map Control{ Control_L, Control_R };
    modifier_map Mod2   { Num_Lock };
    // modifier_map Mod4   { Super_L, Super_R }; // !!!
    modifier_map Mod3   { Super_R }; // !!!
    modifier_map Mod4   { Control_R }; // !!!

    // Fake keys for virtual<->real modifiers mapping:
    key <LVL3> {	[ ISO_Level3_Shift	]	};
    key <MDSW> {	[ Mode_switch 		]	};
    modifier_map Mod5   { <LVL3>, <MDSW> };

    key <ALT>  {	[ NoSymbol, Alt_L	]	};
    include "altwin(meta_alt)"

    key <META> {	[ NoSymbol, Meta_L	]	};
    modifier_map Mod1   { <META> };

    key <SUPR> {	[ NoSymbol, Super_L	]	}; // !!!
    modifier_map Mod4   { <SUPR> };

    key <HYPR> {	[ NoSymbol, Hyper_L	]	};
    modifier_map Mod4   { <HYPR> };
    // End of modifier mappings.

    key <OUTP> { [ XF86Display ] };
    key <KITG> { [ XF86KbdLightOnOff ] };
    key <KIDN> { [ XF86KbdBrightnessDown ] };
    key <KIUP> { [ XF86KbdBrightnessUp ] };

    include "kr(ralt_hangul)" // !!!
    // include "kr(rctrl_hanja)" // !!! not possible for apple aluminium since there is no rctrl
};
'';
      # custom_xkeyboard_config = pkgs.writeTextFile {
      #   name = "us-custom_xkeyboard";
      #   text =  ''
      #     xkb_symbols "custom_xkeyboard"
      #     {
      #       include "us(dvorak)"
      #     };
      #   '';
      #   destination = "/symbols";
      # };
      in
      {
        description = "US layout with sepiabrownn's windows custom patch";
        languages   = [ "eng" ];
        symbolsFile = custom_windows_config;
      };
      extraLayouts.custom_apple =
      let 
        custom_apple_symbols = pkgs.writeText "custom_apple_symbols_xkeyboard"
''
// '!!!' for changes made by sepiabrown
default partial alphanumeric_keys modifier_keys
xkb_symbols "basic" // !!!
{
    include "us(dvorak)" // !!!

    key <ESC>  {	[ 		]	};

    key <RTSH> {	[ Escape		]	};

    //key <LWIN> { [ Alt_L ] };
    //key <RWIN> { [ Alt_R ] };
    //modifier_map Mod1 { <LWIN>, <RWIN> };
    key <LWIN> { [ Caps_Lock ] };
    //key <RWIN> { [ Caps_Lock ] };
    //modifier_map Lock { <LWIN>, <RWIN> };
    modifier_map Mod4 { Super_L };
    modifier_map Mod3 { Super_R };
    key <CAPS> {	[ Super_R		]	};
};
'';
        custom_apple_keycodes = pkgs.writeText "custom_apple_keycodes_xkeyboard" # '!!!' for changes made by sepiabrown
''
xkb_keycodes "custom_apple" {
        include "evdev"
	<FK01> = 232;	// #define KEY_BRIGHTNESSDOWN      224 !!!
	<FK02> = 233;	// #define KEY_BRIGHTNESSUP        225 !!!
	<FK03> = 128;   // #define KEY_SCALE               120 !!!
	<FK04> = 212;   // #define KEY_DASHBOARD           204 !!!
	<FK05> = 237;	// #define KEY_KBDILLUMDOWN        229 !!!
	<FK06> = 238;	// #define KEY_KBDILLUMUP          230 !!!
	<FK07> = 173;	// #define KEY_PREVIOUSSONG        165 !!!
	<FK08> = 172;	// #define KEY_PLAYPAUSE           164 !!!
	<FK09> = 171;	// #define KEY_NEXTSONG            163 !!!
	<FK10> = 121;   // !!!
	<FK11> = 122;   // !!!
        <FK12> = 123;   // !!!

       	// <FK01> = 67;
	// <FK02> = 68;
	// <FK03> = 69;
	// <FK04> = 70;
	// <FK05> = 71;
	// <FK06> = 72;
	// <FK07> = 73;
	// <FK08> = 74;
	// <FK09> = 75;
	// <FK10> = 76;
	// <FK11> = 95;
	// <FK12> = 96;

       	<I232> = 67;
	<I233> = 68;
	<I128> = 69;
	<I212> = 70;
	<I237> = 71;
	<I238> = 72;
	<I173> = 73;
	<I172> = 74;
	<I171> = 75;
	<MUTE> = 76;
	<VOL-> = 95;
	<VOL+> = 96;

	// <I232> = 232;	// #define KEY_BRIGHTNESSDOWN      224
	// <I233> = 233;	// #define KEY_BRIGHTNESSUP        225
	// <I128> = 128;   // #define KEY_SCALE               120
	// <I212> = 212;   // #define KEY_DASHBOARD           204
	// <I237> = 237;	// #define KEY_KBDILLUMDOWN        229
	// <I238> = 238;	// #define KEY_KBDILLUMUP          230
	// <I173> = 173;	// #define KEY_PREVIOUSSONG        165
	// <I172> = 172;	// #define KEY_PLAYPAUSE           164
	// <I171> = 171;	// #define KEY_NEXTSONG            163
	// <MUTE> = 121;
	// <VOL-> = 122;
        // <VOL+> = 123;
};
'';
        custom_apple_keycodes2 = pkgs.writeText "custom_apple_keycodes2_xkeyboard" # '!!!' for changes made by sepiabrown
''
// translation from evdev scancodes to something resembling xfree86 keycodes.

default xkb_keycodes "evdev" {
	minimum = 8;
	maximum = 255;

        # Added for pc105 compatibility
        <LSGT> = 94;

	<TLDE> = 49;
	<AE01> = 10;
	<AE02> = 11;
	<AE03> = 12;
	<AE04> = 13;
	<AE05> = 14;
	<AE06> = 15;
	<AE07> = 16;
	<AE08> = 17;
	<AE09> = 18;
	<AE10> = 19;
	<AE11> = 20;
	<AE12> = 21;
	<BKSP> = 22;

	<TAB> = 23;
	<AD01> = 24;
	<AD02> = 25;
	<AD03> = 26;
	<AD04> = 27;
	<AD05> = 28;
	<AD06> = 29;
	<AD07> = 30;
	<AD08> = 31;
	<AD09> = 32;
	<AD10> = 33;
	<AD11> = 34;
	<AD12> = 35;
	<BKSL> = 51;
	alias <AC12> = <BKSL>;
	<RTRN> = 36;

	<CAPS> = 66;
	<AC01> = 38;
	<AC02> = 39;
	<AC03> = 40;
	<AC04> = 41;
	<AC05> = 42;
	<AC06> = 43;
	<AC07> = 44;
	<AC08> = 45;
	<AC09> = 46;
	<AC10> = 47;
	<AC11> = 48;

	<LFSH> = 50;
	<AB01> = 52;
	<AB02> = 53;
	<AB03> = 54;
	<AB04> = 55;
	<AB05> = 56;
	<AB06> = 57;
	<AB07> = 58;
	<AB08> = 59;
	<AB09> = 60;
	<AB10> = 61;
	<RTSH> = 62;

	<LALT> = 64;
	<LCTL> = 37;
	<SPCE> = 65;
	<RCTL> = 105;
	<RALT> = 108;
	// Microsoft keyboard extra keys
	<LWIN> = 133;
	<RWIN> = 134;
	<COMP> = 135;
	alias <MENU> = <COMP>;

	<ESC> = 9;
	<FK01> = 67;
	<FK02> = 68;
	<FK03> = 69;
	<FK04> = 70;
	<FK05> = 71;
	<FK06> = 72;
	<FK07> = 73;
	<FK08> = 74;
	<FK09> = 75;
	<FK10> = 76;
	<FK11> = 95;
	<FK12> = 96;

	<PRSC> = 107;
	// <SYRQ> = 107;
	<SCLK> = 78;
	<PAUS> = 127;
	// <BRK> = 419;

	<INS> = 118;
	<HOME> = 110;
	<PGUP> = 112;
	<DELE> = 119;
	<END> = 115;
	<PGDN> = 117;

	<UP> = 111;
	<LEFT> = 113;
	<DOWN> = 116;
	<RGHT> = 114;

	<NMLK> = 77;
	<KPDV> = 106;
	<KPMU> = 63;
	<KPSU> = 82;

	<KP7> = 79;
	<KP8> = 80;
	<KP9> = 81;
	<KPAD> = 86;

	<KP4> = 83;
	<KP5> = 84;
	<KP6> = 85;

	<KP1> = 87;
	<KP2> = 88;
	<KP3> = 89;
	<KPEN> = 104;

	<KP0> = 90;
	<KPDL> = 91;
	<KPEQ> = 125;

	<FK13> = 191;
	<FK14> = 192;
	<FK15> = 193;
	<FK16> = 194;
	<FK17> = 195;
	<FK18> = 196;
	<FK19> = 197;
	<FK20> = 198;
	<FK21> = 199;
	<FK22> = 200;
	<FK23> = 201;
	<FK24> = 202;

	// Keys that are generated on Japanese keyboards

	//<HZTG> =  93;	// Hankaku/Zenkakau toggle - not actually used
	alias <HZTG> = <TLDE>;
	<HKTG> = 101;	// Hiragana/Katakana toggle
	<AB11> = 97;	// backslash/underscore
	<HENK> = 100;	// Henkan
	<MUHE> = 102;	// Muhenkan
	<AE13> = 132;	// Yen
	<KATA> =  98;	// Katakana
	<HIRA> =  99;	// Hiragana
	<JPCM> = 103;	// KPJPComma
	//<RO>   =  97;	// Romaji

	// Keys that are generated on Korean keyboards

	<HNGL> = 130;	// Hangul Latin toggle
	<HJCV> = 131;	// Hangul to Hanja conversion

	// Solaris compatibility

	alias <LMTA> = <LWIN>;
	alias <RMTA> = <RWIN>;
	<MUTE> = 121;
	<VOL-> = 122;
	<VOL+> = 123;
	<POWR> = 124;
	<STOP> = 136;
	<AGAI> = 137;
	<PROP> = 138;
	<UNDO> = 139;
	<FRNT> = 140;
	<COPY> = 141;
	<OPEN> = 142;
	<PAST> = 143;
	<FIND> = 144;
	<CUT>  = 145;
	<HELP> = 146;

	// Extended keys that may be generated on "Internet" keyboards.
	// evdev has standardize names for these.

	<LNFD> = 109;	// #define KEY_LINEFEED            101
	<I120> = 120;	// #define KEY_MACRO               112
	<I126> = 126;	// #define KEY_KPPLUSMINUS         118
	<I128> = 128;   // #define KEY_SCALE               120
	<I129> = 129;	// #define KEY_KPCOMMA             121
	<I147> = 147;	// #define KEY_MENU                139
	<I148> = 148;	// #define KEY_CALC                140
	<I149> = 149;	// #define KEY_SETUP               141
	<I150> = 150;	// #define KEY_SLEEP               142
	<I151> = 151;	// #define KEY_WAKEUP              143
	<I152> = 152;	// #define KEY_FILE                144
	<I153> = 153;	// #define KEY_SENDFILE            145
	<I154> = 154;	// #define KEY_DELETEFILE          146
	<I155> = 155;	// #define KEY_XFER                147
	<I156> = 156;	// #define KEY_PROG1               148
	<I157> = 157;	// #define KEY_PROG2               149
	<I158> = 158;	// #define KEY_WWW                 150
	<I159> = 159;	// #define KEY_MSDOS               151
	<I160> = 160;	// #define KEY_COFFEE              152
	<I161> = 161;	// #define KEY_DIRECTION           153
	<I162> = 162;	// #define KEY_CYCLEWINDOWS        154
	<I163> = 163;	// #define KEY_MAIL                155
	<I164> = 164;	// #define KEY_BOOKMARKS           156
	<I165> = 165;	// #define KEY_COMPUTER            157
	<I166> = 166;	// #define KEY_BACK                158
	<I167> = 167;	// #define KEY_FORWARD             159
	<I168> = 168;	// #define KEY_CLOSECD             160
	<I169> = 169;	// #define KEY_EJECTCD             161
	<I170> = 170;	// #define KEY_EJECTCLOSECD        162
	<I171> = 171;	// #define KEY_NEXTSONG            163
	<I172> = 172;	// #define KEY_PLAYPAUSE           164
	<I173> = 173;	// #define KEY_PREVIOUSSONG        165
	<I174> = 174;	// #define KEY_STOPCD              166
	<I175> = 175;	// #define KEY_RECORD              167
	<I176> = 176;	// #define KEY_REWIND              168
	<I177> = 177;	// #define KEY_PHONE               169
	<I178> = 178;	// #define KEY_ISO                 170
	<I179> = 179;	// #define KEY_CONFIG              171
	<I180> = 180;	// #define KEY_HOMEPAGE            172
	<I181> = 181;	// #define KEY_REFRESH             173
	<I182> = 182;	// #define KEY_EXIT                174
	<I183> = 183;	// #define KEY_MOVE                175
	<I184> = 184;	// #define KEY_EDIT                176
	<I185> = 185;	// #define KEY_SCROLLUP            177
	<I186> = 186;	// #define KEY_SCROLLDOWN          178
	<I187> = 187;	// #define KEY_KPLEFTPAREN         179
	<I188> = 188;	// #define KEY_KPRIGHTPAREN        180
	<I189> = 189;	// #define KEY_NEW                 181
	<I190> = 190;	// #define KEY_REDO                182
	<I208> = 208;	// #define KEY_PLAYCD              200
	<I209> = 209;	// #define KEY_PAUSECD             201
	<I210> = 210;	// #define KEY_PROG3               202
	<I211> = 211;	// #define KEY_PROG4               203 conflicts with AB11
	<I212> = 212;   // #define KEY_DASHBOARD           204
	<I213> = 213;	// #define KEY_SUSPEND             205
	<I214> = 214;	// #define KEY_CLOSE               206
	<I215> = 215;	// #define KEY_PLAY                207
	<I216> = 216;	// #define KEY_FASTFORWARD         208
	<I217> = 217;	// #define KEY_BASSBOOST           209
	<I218> = 218;	// #define KEY_PRINT               210
	<I219> = 219;	// #define KEY_HP                  211
	<I220> = 220;	// #define KEY_CAMERA              212
	<I221> = 221;	// #define KEY_SOUND               213
	<I222> = 222;	// #define KEY_QUESTION            214
	<I223> = 223;	// #define KEY_EMAIL               215
	<I224> = 224;	// #define KEY_CHAT                216
	<I225> = 225;	// #define KEY_SEARCH              217
	<I226> = 226;	// #define KEY_CONNECT             218
	<I227> = 227;	// #define KEY_FINANCE             219
	<I228> = 228;	// #define KEY_SPORT               220
	<I229> = 229;	// #define KEY_SHOP                221
	<I230> = 230;	// #define KEY_ALTERASE            222
	<I231> = 231;	// #define KEY_CANCEL              223
	<I232> = 232;	// #define KEY_BRIGHTNESSDOWN      224
	<I233> = 233;	// #define KEY_BRIGHTNESSUP        225
	<I234> = 234;	// #define KEY_MEDIA               226
	<I235> = 235;	// #define KEY_SWITCHVIDEOMODE     227
	<I236> = 236;	// #define KEY_KBDILLUMTOGGLE      228
	<I237> = 237;	// #define KEY_KBDILLUMDOWN        229
	<I238> = 238;	// #define KEY_KBDILLUMUP          230
	<I239> = 239;	// #define KEY_SEND                231
	<I240> = 240;	// #define KEY_REPLY               232
	<I241> = 241;	// #define KEY_FORWARDMAIL         233
	<I242> = 242;	// #define KEY_SAVE                234
	<I243> = 243;	// #define KEY_DOCUMENTS           235
	<I244> = 244;	// #define KEY_BATTERY             236
	<I245> = 245;	// #define KEY_BLUETOOTH           237
	<I246> = 246;	// #define KEY_WLAN                238
	<I247> = 247;	// #define KEY_UWB                 239
	<I248> = 248;	// #define KEY_UNKNOWN             240
	<I249> = 249;	// #define KEY_VIDEO_NEXT          241
	<I250> = 250;	// #define KEY_VIDEO_PREV          242
	<I251> = 251;	// #define KEY_BRIGHTNESS_CYCLE    243
	<I252> = 252;	// #define KEY_BRIGHTNESS_ZERO     244
	<I253> = 253;	// #define KEY_DISPLAY_OFF         245
	<I254> = 254;	// #define KEY_WWAN                246
	<I255> = 255;	// #define KEY_RFKILL              247

	<I372> = 372;   // #define KEY_FAVORITES           364
	<I380> = 380;   // #define KEY_FULL_SCREEN         372
	<I382> = 382;   // #define KEY_KEYBOARD            374
	<I442> = 442;   // #define KEY_DOLLAR              434
	<I443> = 443;   // #define KEY_EURO                435
	<I569> = 569;   // #define KEY_ROTATE_LOCK_TOGGLE  561

	// Fake keycodes for virtual keys
	<LVL3> =   92;
	<MDSW> =   203;
	<ALT>  =   204;
	<META> =   205;
	<SUPR> =   206;
	<HYPR> =   207;

	indicator 1  = "Caps Lock";
	indicator 2  = "Num Lock";
	indicator 3  = "Scroll Lock";
	indicator 4  = "Compose";
	indicator 5  = "Kana";
	indicator 6  = "Sleep";
	indicator 7  = "Suspend";
	indicator 8  = "Mute";
	indicator 9  = "Misc";
	indicator 10 = "Mail";
	indicator 11 = "Charging";

	alias <ALGR> = <RALT>;

	// For Brazilian ABNT2
	alias <KPPT> = <I129>;
};
'';
        custom_apple_keycodes3 = pkgs.writeText "custom_apple_keycodes3_xkeyboard" # '!!!' for changes made by sepiabrown : volume swap
''
// translation from evdev scancodes to something resembling xfree86 keycodes.

default xkb_keycodes "evdev" {
	minimum = 8;
	maximum = 255;

        # Added for pc105 compatibility
        <LSGT> = 94;

	<TLDE> = 49;
	<AE01> = 10;
	<AE02> = 11;
	<AE03> = 12;
	<AE04> = 13;
	<AE05> = 14;
	<AE06> = 15;
	<AE07> = 16;
	<AE08> = 17;
	<AE09> = 18;
	<AE10> = 19;
	<AE11> = 20;
	<AE12> = 21;
	<BKSP> = 22;

	<TAB> = 23;
	<AD01> = 24;
	<AD02> = 25;
	<AD03> = 26;
	<AD04> = 27;
	<AD05> = 28;
	<AD06> = 29;
	<AD07> = 30;
	<AD08> = 31;
	<AD09> = 32;
	<AD10> = 33;
	<AD11> = 34;
	<AD12> = 35;
	<BKSL> = 51;
	alias <AC12> = <BKSL>;
	<RTRN> = 36;

	<CAPS> = 66;
	<AC01> = 38;
	<AC02> = 39;
	<AC03> = 40;
	<AC04> = 41;
	<AC05> = 42;
	<AC06> = 43;
	<AC07> = 44;
	<AC08> = 45;
	<AC09> = 46;
	<AC10> = 47;
	<AC11> = 48;

	<LFSH> = 50;
	<AB01> = 52;
	<AB02> = 53;
	<AB03> = 54;
	<AB04> = 55;
	<AB05> = 56;
	<AB06> = 57;
	<AB07> = 58;
	<AB08> = 59;
	<AB09> = 60;
	<AB10> = 61;
	<RTSH> = 62;

	<LALT> = 64;
	<LCTL> = 37;
	<SPCE> = 65;
	<RCTL> = 105;
	<RALT> = 108;
	// Microsoft keyboard extra keys
	<LWIN> = 133;
	<RWIN> = 134;
	<COMP> = 135;
	alias <MENU> = <COMP>;

	<ESC> = 9;
	<FK01> = 67;
	<FK02> = 68;
	<FK03> = 69;
	<FK04> = 70;
	<FK05> = 71;
	<FK06> = 72;
	<FK07> = 73;
	<FK08> = 74;
	<FK09> = 75;
	<FK10> = 76;
	<FK11> = 95;
	<FK12> = 96;

	<PRSC> = 107;
	// <SYRQ> = 107;
	<SCLK> = 78;
	<PAUS> = 127;
	// <BRK> = 419;

	<INS> = 118;
	<HOME> = 110;
	<PGUP> = 112;
	<DELE> = 119;
	<END> = 115;
	<PGDN> = 117;

	<UP> = 111;
	<LEFT> = 113;
	<DOWN> = 116;
	<RGHT> = 114;

	<NMLK> = 77;
	<KPDV> = 106;
	<KPMU> = 63;
	<KPSU> = 82;

	<KP7> = 79;
	<KP8> = 80;
	<KP9> = 81;
	<KPAD> = 86;

	<KP4> = 83;
	<KP5> = 84;
	<KP6> = 85;

	<KP1> = 87;
	<KP2> = 88;
	<KP3> = 89;
	<KPEN> = 104;

	<KP0> = 90;
	<KPDL> = 91;
	<KPEQ> = 125;

	<FK13> = 191;
	<FK14> = 192;
	<FK15> = 193;
	<FK16> = 194;
	<FK17> = 195;
	<FK18> = 196;
	<FK19> = 197;
	<FK20> = 198;
	<FK21> = 199;
	<FK22> = 200;
	<FK23> = 201;
	<FK24> = 202;

	// Keys that are generated on Japanese keyboards

	//<HZTG> =  93;	// Hankaku/Zenkakau toggle - not actually used
	alias <HZTG> = <TLDE>;
	<HKTG> = 101;	// Hiragana/Katakana toggle
	<AB11> = 97;	// backslash/underscore
	<HENK> = 100;	// Henkan
	<MUHE> = 102;	// Muhenkan
	<AE13> = 132;	// Yen
	<KATA> =  98;	// Katakana
	<HIRA> =  99;	// Hiragana
	<JPCM> = 103;	// KPJPComma
	//<RO>   =  97;	// Romaji

	// Keys that are generated on Korean keyboards

	<HNGL> = 130;	// Hangul Latin toggle
	<HJCV> = 131;	// Hangul to Hanja conversion

	// Solaris compatibility

	alias <LMTA> = <LWIN>;
	alias <RMTA> = <RWIN>;
	<MUTE> = 121;
	<VOL-> = 123;
	<VOL+> = 122;
	<POWR> = 124;
	<STOP> = 136;
	<AGAI> = 137;
	<PROP> = 138;
	<UNDO> = 139;
	<FRNT> = 140;
	<COPY> = 141;
	<OPEN> = 142;
	<PAST> = 143;
	<FIND> = 144;
	<CUT>  = 145;
	<HELP> = 146;

	// Extended keys that may be generated on "Internet" keyboards.
	// evdev has standardize names for these.

	<LNFD> = 109;	// #define KEY_LINEFEED            101
	<I120> = 120;	// #define KEY_MACRO               112
	<I126> = 126;	// #define KEY_KPPLUSMINUS         118
	<I128> = 128;   // #define KEY_SCALE               120
	<I129> = 129;	// #define KEY_KPCOMMA             121
	<I147> = 147;	// #define KEY_MENU                139
	<I148> = 148;	// #define KEY_CALC                140
	<I149> = 149;	// #define KEY_SETUP               141
	<I150> = 150;	// #define KEY_SLEEP               142
	<I151> = 151;	// #define KEY_WAKEUP              143
	<I152> = 152;	// #define KEY_FILE                144
	<I153> = 153;	// #define KEY_SENDFILE            145
	<I154> = 154;	// #define KEY_DELETEFILE          146
	<I155> = 155;	// #define KEY_XFER                147
	<I156> = 156;	// #define KEY_PROG1               148
	<I157> = 157;	// #define KEY_PROG2               149
	<I158> = 158;	// #define KEY_WWW                 150
	<I159> = 159;	// #define KEY_MSDOS               151
	<I160> = 160;	// #define KEY_COFFEE              152
	<I161> = 161;	// #define KEY_DIRECTION           153
	<I162> = 162;	// #define KEY_CYCLEWINDOWS        154
	<I163> = 163;	// #define KEY_MAIL                155
	<I164> = 164;	// #define KEY_BOOKMARKS           156
	<I165> = 165;	// #define KEY_COMPUTER            157
	<I166> = 166;	// #define KEY_BACK                158
	<I167> = 167;	// #define KEY_FORWARD             159
	<I168> = 168;	// #define KEY_CLOSECD             160
	<I169> = 169;	// #define KEY_EJECTCD             161
	<I170> = 170;	// #define KEY_EJECTCLOSECD        162
	<I171> = 171;	// #define KEY_NEXTSONG            163
	<I172> = 172;	// #define KEY_PLAYPAUSE           164
	<I173> = 173;	// #define KEY_PREVIOUSSONG        165
	<I174> = 174;	// #define KEY_STOPCD              166
	<I175> = 175;	// #define KEY_RECORD              167
	<I176> = 176;	// #define KEY_REWIND              168
	<I177> = 177;	// #define KEY_PHONE               169
	<I178> = 178;	// #define KEY_ISO                 170
	<I179> = 179;	// #define KEY_CONFIG              171
	<I180> = 180;	// #define KEY_HOMEPAGE            172
	<I181> = 181;	// #define KEY_REFRESH             173
	<I182> = 182;	// #define KEY_EXIT                174
	<I183> = 183;	// #define KEY_MOVE                175
	<I184> = 184;	// #define KEY_EDIT                176
	<I185> = 185;	// #define KEY_SCROLLUP            177
	<I186> = 186;	// #define KEY_SCROLLDOWN          178
	<I187> = 187;	// #define KEY_KPLEFTPAREN         179
	<I188> = 188;	// #define KEY_KPRIGHTPAREN        180
	<I189> = 189;	// #define KEY_NEW                 181
	<I190> = 190;	// #define KEY_REDO                182
	<I208> = 208;	// #define KEY_PLAYCD              200
	<I209> = 209;	// #define KEY_PAUSECD             201
	<I210> = 210;	// #define KEY_PROG3               202
	<I211> = 211;	// #define KEY_PROG4               203 conflicts with AB11
	<I212> = 212;   // #define KEY_DASHBOARD           204
	<I213> = 213;	// #define KEY_SUSPEND             205
	<I214> = 214;	// #define KEY_CLOSE               206
	<I215> = 215;	// #define KEY_PLAY                207
	<I216> = 216;	// #define KEY_FASTFORWARD         208
	<I217> = 217;	// #define KEY_BASSBOOST           209
	<I218> = 218;	// #define KEY_PRINT               210
	<I219> = 219;	// #define KEY_HP                  211
	<I220> = 220;	// #define KEY_CAMERA              212
	<I221> = 221;	// #define KEY_SOUND               213
	<I222> = 222;	// #define KEY_QUESTION            214
	<I223> = 223;	// #define KEY_EMAIL               215
	<I224> = 224;	// #define KEY_CHAT                216
	<I225> = 225;	// #define KEY_SEARCH              217
	<I226> = 226;	// #define KEY_CONNECT             218
	<I227> = 227;	// #define KEY_FINANCE             219
	<I228> = 228;	// #define KEY_SPORT               220
	<I229> = 229;	// #define KEY_SHOP                221
	<I230> = 230;	// #define KEY_ALTERASE            222
	<I231> = 231;	// #define KEY_CANCEL              223
	<I232> = 232;	// #define KEY_BRIGHTNESSDOWN      224
	<I233> = 233;	// #define KEY_BRIGHTNESSUP        225
	<I234> = 234;	// #define KEY_MEDIA               226
	<I235> = 235;	// #define KEY_SWITCHVIDEOMODE     227
	<I236> = 236;	// #define KEY_KBDILLUMTOGGLE      228
	<I237> = 237;	// #define KEY_KBDILLUMDOWN        229
	<I238> = 238;	// #define KEY_KBDILLUMUP          230
	<I239> = 239;	// #define KEY_SEND                231
	<I240> = 240;	// #define KEY_REPLY               232
	<I241> = 241;	// #define KEY_FORWARDMAIL         233
	<I242> = 242;	// #define KEY_SAVE                234
	<I243> = 243;	// #define KEY_DOCUMENTS           235
	<I244> = 244;	// #define KEY_BATTERY             236
	<I245> = 245;	// #define KEY_BLUETOOTH           237
	<I246> = 246;	// #define KEY_WLAN                238
	<I247> = 247;	// #define KEY_UWB                 239
	<I248> = 248;	// #define KEY_UNKNOWN             240
	<I249> = 249;	// #define KEY_VIDEO_NEXT          241
	<I250> = 250;	// #define KEY_VIDEO_PREV          242
	<I251> = 251;	// #define KEY_BRIGHTNESS_CYCLE    243
	<I252> = 252;	// #define KEY_BRIGHTNESS_ZERO     244
	<I253> = 253;	// #define KEY_DISPLAY_OFF         245
	<I254> = 254;	// #define KEY_WWAN                246
	<I255> = 255;	// #define KEY_RFKILL              247

	<I372> = 372;   // #define KEY_FAVORITES           364
	<I380> = 380;   // #define KEY_FULL_SCREEN         372
	<I382> = 382;   // #define KEY_KEYBOARD            374
	<I442> = 442;   // #define KEY_DOLLAR              434
	<I443> = 443;   // #define KEY_EURO                435
	<I569> = 569;   // #define KEY_ROTATE_LOCK_TOGGLE  561

	// Fake keycodes for virtual keys
	<LVL3> =   92;
	<MDSW> =   203;
	<ALT>  =   204;
	<META> =   205;
	<SUPR> =   206;
	<HYPR> =   207;

	indicator 1  = "Caps Lock";
	indicator 2  = "Num Lock";
	indicator 3  = "Scroll Lock";
	indicator 4  = "Compose";
	indicator 5  = "Kana";
	indicator 6  = "Sleep";
	indicator 7  = "Suspend";
	indicator 8  = "Mute";
	indicator 9  = "Misc";
	indicator 10 = "Mail";
	indicator 11 = "Charging";

	alias <ALGR> = <RALT>;

	// For Brazilian ABNT2
	alias <KPPT> = <I129>;
};
'';
      in
      {
        description = "US layout with sepiabrownn's apple aluminium custom patch";
        languages   = [ "eng" ];
        symbolsFile = custom_apple_symbols;
        keycodesFile = custom_apple_keycodes2;
      };
    };
  };
}
#
# Check out
# cd /nix/store/5vn5ndrjbmvw5aakv9lpxjwnjkan8ssl-xkeyboard-config-2.31/share/X11/xkb/symbols
#
# Useful Sites
# https://www.x.org/releases/current/doc/xorg-docs/input/XKB-Enhancing.html#Defining_New_Layouts
# https://www.charvolant.org/doug/xkb/html/node5.html
# https://nixos.org/manual/nixos/stable/#custom-xkb-layouts
# https://wiki.archlinux.org/title/X_keyboard_extension
#
# Useful Facts
# - Keys that are assigned to Mod4 keys(usually Super keys in default) open up windows menu!
# //////////wrong?- To Disable that, you need to erase Super keys in Mod4 keys and ALSO assign it to other Mod keys like lock! (modifier_map Lock)
# - In symbols files, code written latter overrides the former (I think).
# - sepiabrown is using Mod3 keys for activating xmonad commands!
# ex) Mod3 + Shift_L + RTRN = terminal
#
# XKB compiler errors meaning:
# ex) custom_apple:18:5: syntax error
# custom_apple file was as follows:
#1
#2 // '!!!' for changes made by sepiabrown
#3 default partial alphanumeric_keys modifier_keys
#4 xkb_symbols "basic" // !!!
#5 {
#6     include "us(dvorak)" // !!!
#7 
#8     key <ESC>  {	[ 		]	};
#9 
#10    key <RTSH> {	[ Escape		]	};
#11 
#12    //key <LWIN> { [ Alt_L ] };
#13    //key <RWIN> { [ Alt_R ] };
#14    //modifier_map Mod1 { <LWIN>, <RWIN> };
#15    key <LWIN> { [ Caps_Lock ] };
#16    //key <RWIN> { [ Caps_Lock ] };
#17    //modifier_map Lock { <LWIN>, <RWIN> };
#18    modifier_map Mod4 { Super_L }
#     modifier_map Mod3 { Super_R }
# };
# 18:5 means line 18 block 5. 
# modifier_map(1) Mod4(2) {(3) Super_L(4) }(5) 
# } doesn't include ; so error!
#
# Useful commands:
# xmodmap
# - shows modifier_map keys mapping to special keys
# setxkbmap -print -verbose 10
# - shows current state of xkeyboard
# - nix-build --no-out-link '<nixpkgs>' -A xorg.xkeyboardconfig
#
# What I figured out about how modifier_map works (maybe wrong):
# ex)   
# At ~~/share/X11/xkb/symbols/pc
# ...
# key <LWIN> {	[ Super_L		]	};
# ...
# key <RWIN> {	[ Super_R		]	};
# ...
# modifier_map Mod4   { Super_L, Super_R };
# bachman 2003 Geometric Approach to Differential Forms   
# key codes in the ex) : <LWIN>, <RWIN>
# symbols in the ex) : Super_L, Super_R
#
# ex) maps keys in the following logic:
# <LWIN> => Super_L => Mod4
# <RWIN> => Super_R => Mod4
#
# if you don't want <LWIN> to open up windows menu (or equivalent menu poping up from the bottom), 
# 1. Redirect <LWIN>, <RWIN> to other keys which breaks <LWIN> => Mod4 Link
# 2. Redirect modifier_map Mod4 to other symbols also breaking the link
# Usually 1 is preferred because (I think) it is going to be more consistent with other applications/system to preserve the modifier_map and symbol link instead of preserving key code and symbol link.
