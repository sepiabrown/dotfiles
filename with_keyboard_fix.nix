# Instruction at the back!
#
{ config, pkgs, ... }:

{
  console.useXkbConfig = true; # apply this setting in outside of X11; configure the virtual console keymap from the xserver keyboard settings. 
  services = {
    xserver = { 
      # Configure keymap in X11
      # xkbModel = "pc105"; not used in extraLayouts
      # Disable plasma application menu popup: https://www.reddit.com/r/kde/comments/9uspp8/how_do_i_disable_the_plasma_application_menu_pop/  https://zren.github.io/kde/#windowsmeta-key
      # kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "" qdbus org.kde.KWin /KWin reconfigure
      # to enable meta to turn on application launcher in kde plasma, erase ~/.config/kwinrc to reset or put 'kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu" qdbus org.kde.KWin /KWin reconfigure' in the if statement instead.
      layout = "sb";
      extraLayouts.sb = # Suwon_non_darwin: real xkb symbol file name
      let 
        sb_non_darwin_config_220924 = pkgs.writeText "sb_non_darwin_xkeyboard_220924" # sb_non_darwin_xkeyboard_220924 : patch file name
''
// '!!!' : changes made by sb
default partial alphanumeric_keys modifier_keys
xkb_symbols "basic" // !!!
{
    include "us(dvorak)" // !!!
    // key <ESC>  {	[ Escape		]	};
    key <ESC>  {	[ Shift_R		]	}; // !!!

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
};
'';
      in
      {
        description = "US dvorak layout with sepiabrown's patch";
        languages   = [ "eng" ];
        symbolsFile = sb_non_darwin_config_220924;
      };

      extraLayouts.sb_darwin =
      let 
        sb_darwin_config_220924 = pkgs.writeText "sb_darwin_xkeyboard_220924"
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
        description = "US dvorak layout with sepiabrown's patch for apple aluminium magic keyboard";
        languages   = [ "eng" ];
        symbolsFile = sb_darwin_config_220924;
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
# https://nixos.org/manual/nixos/stable/#Suwon-xkb-layouts
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
# ex) Suwon_apple:18:5: syntax error
# Suwon_apple file was as follows:
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
#
# Fcitx observations
# - 한 + sb_non_darwin_220924 : seobeulsik not working, Caps Lock not working, ESC at RShift too
# - 한 + English(Dvorak) : seobeulsik not working, Caps Lock at Windows, ESC at RShift too
# - 한 + English(US) : seobeulsik not working, Caps Lock at Windows, ESC at RShift too
# - 키보드 표시 + sb_non_darwin_220924 : dvorak working, Caps Lock at Windows, ESC at RShift too
# - 키보드 표시 + English(Dvorak) : dvorak working, Caps Lock at Windows, ESC at RShift too
# - 키보드 표시 + English(US) : dvorak not working, Caps Lock at Windows, ESC at RShift too

