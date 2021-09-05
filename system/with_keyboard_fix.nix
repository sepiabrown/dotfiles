{ config, pkgs, ... }:

{
  imports = [ ./configuration_basic.nix ]
  services = {
    xserver = { 
      # Configure keymap in X11
      xkbModel = "presario";
      layout = "custom_xkeyboard";
      xkbVariant = "ESC_CAPS_fixed";
      xkbOptions = "grp:caps_toggle,grp_led:scroll";
      extraLayouts.custom_xkeyboard = # custom_xkeyboard : real xkb symbol file name(maybe?) 
      let 
      custom_xkeyboard_config = pkgs.writeText "us-custom_xkeyboard" # us-custom_xkeyboard : patch file name
''
default partial alphanumeric_keys modifier_keys
xkb_symbols "ESC_CAPS_fixed"
{
// Edited by sepiabrown : search for '!!!'
    // include "us(dvorak)"
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
    modifier_map Mod4   { Super_L, Super_R };

    // Fake keys for virtual<->real modifiers mapping:
    key <LVL3> {	[ ISO_Level3_Shift	]	};
    key <MDSW> {	[ Mode_switch 		]	};
    modifier_map Mod5   { <LVL3>, <MDSW> };

    key <ALT>  {	[ NoSymbol, Alt_L	]	};
    include "altwin(meta_alt)"

    key <META> {	[ NoSymbol, Meta_L	]	};
    modifier_map Mod1   { <META> };

    key <SUPR> {	[ NoSymbol, Super_L	]	};
    modifier_map Mod4   { <SUPR> };

    key <HYPR> {	[ NoSymbol, Hyper_L	]	};
    
    modifier_map Mod3   { Super_R }; // !!!
    modifier_map Mod4   { Super_L }; // !!!
    modifier_map Mod4   { <HYPR> };
    // End of modifier mappings.

    key <OUTP> { [ XF86Display ] };
    key <KITG> { [ XF86KbdLightOnOff ] };
    key <KIDN> { [ XF86KbdBrightnessDown ] };
    key <KIUP> { [ XF86KbdBrightnessUp ] };

    include "kr(ralt_hangul)" // !!!
    include "kr(rctrl_hanja)" // !!!
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
        description = "US layout with sepiabrown's custom patch";
        languages   = [ "eng" ];
        symbolsFile = custom_xkeyboard_config;
      };
    };
  };
}

