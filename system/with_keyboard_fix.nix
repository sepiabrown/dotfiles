# Instruction at the back!
#
{ config, pkgs, ... }:

{
  services = {
    xserver = { 
      # Configure keymap in X11
      # xkbModel = "pc105"; not used in extraLayouts
      # displayManager.sessionCommands = "setxkbmap -symbols \"us(dvorak)\" -option \"terminate:ctrl_alt_bksp\""; doesn't work
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
      custom_apple_config = pkgs.writeText "apple_custom_xkeyboard"
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
      in
      {
        description = "US layout with sepiabrownn's apple aluminium custom patch";
        languages   = [ "eng" ];
        symbolsFile = custom_apple_config;
      };
    };
  };
}
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
#
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
# 
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
