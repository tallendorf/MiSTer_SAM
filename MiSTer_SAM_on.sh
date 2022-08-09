#!/bin/bash

# https://github.com/mrchrisster/MiSTer_SAM/
# Copyright (c) 2021 by mrchrisster and Mellified

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Description
# This cycles through arcade and console cores periodically
# Games are randomly pulled from their respective folders

# ======== Credits ========
# Original concept and implementation: mrchrisster
# Additional development and script layout: Mellified and Paradox
#
# Thanks for the contributions and support:
# pocomane, kaloun34, redsteakraw, RetroDriven, woelper, LamerDeluxe, InquisitiveCoder, Sigismond
# tty2oled improvements by venice


# ======== INI VARIABLES ========
# Change these in the INI file
function init_vars() {
	# ======== GLOBAL VARIABLES =========
	declare -g mrsampath="/media/fat/Scripts/.MiSTer_SAM"
	declare -g misterpath="/media/fat"
	# Save our PID and process
	declare -g sampid="${$}"
	declare -g samprocess="$(basename -- ${0})"
	declare -gi inmenu=0
	declare -gi tty_counter=0
	
	# ======== DEBUG VARIABLES ========
	declare -gl samquiet="Yes"
	declare -gl samdebug="No"
	declare -gl samtrace="No"

	# ======== LOCAL VARIABLES ========
	declare -gi coreretries=3
	declare -gi romloadfails=0
	declare -g gamelistpath="${mrsampath}/SAM_Gamelists"
	declare -g gamelistpathtmp="/tmp/.SAM_List/"
	declare -g excludepath="${mrsampath}"
	declare -g mralist_old="${mrsampath}/SAM_Gamelists/arcade_romlist"
	declare -g mralist="${mrsampath}/SAM_Gamelists/arcade_gamelist.txt"
	declare -g mralist_tmp_old="/tmp/.SAM_List/arcade_romlist"
	declare -g mralist_tmp="/tmp/.SAM_List/arcade_gamelist.txt"
	declare -g tmpfile="/tmp/.SAM_List/tmpfile"
	declare -g tmpfile2="/tmp/.SAM_List/tmpfile2"
	declare -g corelisttmpfile="/tmp/.SAM_List/corelist.tmp"													 
	declare -gi gametimer=120
	declare -gl corelist="arcade,atari2600,atari5200,atari7800,atarilynx,amiga,c64,fds,gb,gbc,gba,genesis,gg,megacd,neogeo,nes,s32x,sms,snes,tgfx16,tgfx16cd,psx"
	# Make all cores available for menu
	declare -gl corelistall="${corelist}"
	declare -gl create_all_gamelists="No"
	declare -gl skipmessage="Yes"
	declare -gl usezip="Yes"
	declare -gl norepeat="Yes"
	declare -gl disablebootrom="Yes"
	declare -gl mute="Yes"
	declare -gl playcurrentgame="No"
	declare -gl listenmouse="Yes"
	declare -gl listenkeyboard="Yes"
	declare -gl listenjoy="Yes"
	declare -g repository_url="https://github.com/mrchrisster/MiSTer_SAM"
	declare -g branch="main"
	declare -gi counter=0
	declare -g userstartup="/media/fat/linux/user-startup.sh"
	declare -g userstartuptpl="/media/fat/linux/_user-startup.sh"
	declare -gl neogeoregion="English"
	declare -gl useneogeotitles="Yes"
	declare -gl rebuild_freq="Week"
	declare -gi regen_duration=4
	declare -gi rebuild_freq_int="604800"
	declare -gl rebuild_freq_arcade="Week"
	declare -gi regen_duration_arcade=1
	declare -gi rebuild_freq_arcade_int="604800"
	declare -gi bootsleep="60"
	declare -gi countdown="nocountdown"								
	# ======== BGM =======
	declare -gl bgm="No"

	# ======== TTY2OLED =======

	declare -gl ttyenable="No"
	declare -gi ttyupdate_pause=10
	declare -gA tty_currentinfo=(
		[core_pretty]=""
		[name]=""
		[core]=""
		[counter]=0
		[name_scroll]=""
		[name_scroll_position]=0
		[name_scroll_direction]=1
		[update_pause]=${ttyupdate_pause}
	)

	declare -g ttydevice="/dev/ttyUSB0"
	declare -g ttysystemini="/media/fat/tty2oled/tty2oled-system.ini"
	declare -g ttyuserini="/media/fat/tty2oled/tty2oled-user.ini"
	declare -g ttypicture="/media/fat/tty2oled/pics"
	declare -g ttypicture_pri="/media/fat/tty2oled/pics_pri"
	declare -g prev_name_scroll=""
	declare -g prev_counter=""
	declare -gi ttyscroll_speed=1
	declare -gi ttyscroll_speed_int=$((${ttyscroll_speed} - 1))

	# ======== CORE PATHS ========
	declare -g amigapath="/media/fat/Games/Amiga"	
	declare -g arcadepath="/media/fat/_Arcade"
	declare -g atari2600path="/media/fat/Games/Atari7800"
	declare -g atari5200path="/media/fat/Games/Atari5200"
	declare -g atari7800path="/media/fat/Games/Atari7800"
	declare -g atarilynxpath="/media/fat/Games/AtariLynx"
	declare -g c64path="/media/fat/Games/C64"
	declare -g fdspath="/media/fat/Games/NES"
	declare -g gbpath="/media/fat/Games/Gameboy"
	declare -g gbcpath="/media/fat/Games/Gameboy"
	declare -g gbapath="/media/fat/Games/GBA"
	declare -g genesispath="/media/fat/Games/Genesis"
	declare -g ggpath="/media/fat/Games/SMS"
	declare -g megacdpath="/media/fat/Games/MegaCD"
	declare -g neogeopath="/media/fat/Games/NeoGeo"
	declare -g nespath="/media/fat/Games/NES"
	declare -g s32xpath="/media/fat/Games/S32X"
	declare -g smspath="/media/fat/Games/SMS"
	declare -g snespath="/media/fat/Games/SNES"
	declare -g tgfx16path="/media/fat/Games/TGFX16"
	declare -g tgfx16cdpath="/media/fat/Games/TGFX16-CD"
	declare -g psxpath="/media/fat/Games/PSX"

	# ======== CORE PATHS EXTRA ========
	declare -g amigapathextra=""
	declare -g arcadepathextra=""
	declare -g atari2600pathextra=""
	declare -g atari5200pathextra=""
	declare -g atari7800pathextra=""
	declare -g atarilynxpathextra=""
	declare -g c64pathextra=""
	declare -g fdspathextra=""
	declare -g gbpathextra=""
	declare -g gbcpathextra=""
	declare -g gbapathextra=""
	declare -g genesispathextra=""
	declare -g ggpathextra=""
	declare -g megacdpathextra=""
	declare -g neogeopathextra=""
	declare -g nespathextra=""
	declare -g s32xpathextra=""
	declare -g smspathextra=""
	declare -g snespathextra=""
	declare -g tgfx16pathextra=""
	declare -g tgfx16cdpathextra=""
	declare -g psxpathextra=""

	# ======== CORE PATHS RBF ========
	declare -g amigapathrbf="_Computer"
	declare -g arcadepathrbf="_Arcade"
	declare -g atari2600pathrbf="_Console"
	declare -g atari5200pathrbf="_Console"
	declare -g atari7800pathrbf="_Console"
	declare -g atarilynxpathrbf="_Console"
	declare -g c64pathrbf="_Computer"
	declare -g fdspathrbf="_Console"
	declare -g gbpathrbf="_Console"
	declare -g gbcpathrbf="_Console"
	declare -g gbapathrbf="_Console"
	declare -g genesispathrbf="_Console"
	declare -g ggpathrbf="_Console"
	declare -g megacdpathrbf="_Console"
	declare -g neogeopathrbf="_Console"
	declare -g nespathrbf="_Console"
	declare -g s32xpathrbf="_Console"
	declare -g smspathrbf="_Console"
	declare -g snespathrbf="_Console"
	declare -g tgfx16pathrbf="_Console"
	declare -g tgfx16cdpathrbf="_Console"
	declare -g psxpathrbf="_Console"


}

function update_tasks() {
	[ -s "${mralist_old}" ] && { mv "${mralist_old}" "${mralist}"; }
	[ -s "${mralist_tmp_old}" ] && { mv "${mralist_tmp_old}" "${mralist_tmp}"; }
}									 

function init_paths() {
	# Create folders if they don't exist
	mkdir -p "${mrsampath}/SAM_Gamelists"
	[ -d "/tmp/.SAM_List" ] && rm -rf /tmp/.SAM_List
	mkdir -p /tmp/.SAM_List
	[ -e "${tmpfile}" ] && { rm "${tmpfile}"; }
	[ -e "${tmpfile2}" ] && { rm "${tmpfile2}"; }
	[ -e "${corelisttmpfile}" ] && { rm "${corelisttmpfile}"; }
	touch "${tmpfile}"
	touch "${tmpfile2}"
	touch "${corelisttmpfile}"

}

function sam_prep() {
	[ ! -d "/tmp/.SAM_tmp/SAM_config" ] && mkdir -p "/tmp/.SAM_tmp/SAM_config"
	[ -d "/tmp/.SAM_tmp/SAM_config" ] && cp -r --force /media/fat/config/* /tmp/.SAM_tmp/SAM_config &>/dev/null
	[ -f "/tmp/.SAM_tmp/SAM_config/minimig.cfg" ] && cp /tmp/.SAM_tmp/SAM_config/minimig.cfg /tmp/.SAM_tmp/SAM_config/Minimig.cfg 2>/dev/null
	[ -d "/tmp/.SAM_tmp/SAM_config" ] && [ "$(mount | grep -ic '/media/fat/config')" == "0" ] && mount --bind "/tmp/.SAM_tmp/SAM_config" "/media/fat/config"
	[ ! -d "/tmp/.SAM_tmp/Amiga_shared" ] && mkdir -p "/tmp/.SAM_tmp/Amiga_shared"
	[ -d "${amigapath}/shared" ] && cp -r --force ${amigapath}/shared/* /tmp/.SAM_tmp/Amiga_shared &>/dev/null
	[ -d "${amigapath}/shared" ] && [ "$(mount | grep -ic ${amigapath}/shared)" == "0" ] && mount --bind "/tmp/.SAM_tmp/Amiga_shared" "${amigapath}/shared"
	# Stopping tty2oled Daemon
	if [ "${samquiet}" == "no" ]; then echo -n " Stopping tty2oled Daemon..."; fi
	mapfile -t killtty < <(ps -o pid,args | grep '[t]ty2oled.sh' | awk '{print $1}')
	for kill in ${killtty[@]}; do
		[[ ! -z "${killtty}" ]] && kill -9 ${kill}
	done
	if [ "${samquiet}" == "no" ]; then echo " Done!"; fi

}

function sam_cleanup() {
	tty_exit &
	bgm_stop
	# Clean up by umounting any mount binds
	[ "$(mount | grep -ic '/media/fat/config')" == "1" ] && umount "/media/fat/config"
	[ "$(mount | grep -ic ${amigapath}/shared)" == "1" ] && umount "${amigapath}/shared"
	[ -d "${misterpath}/Bootrom" ] && [ "$(mount | grep -ic 'bootrom')" == "1" ] && umount "${misterpath}/Bootrom"
	[ -f "${misterpath}/Games/NES/boot1.rom" ] && [ "$(mount | grep -ic 'nes/boot1.rom')" == "1" ] && umount "${misterpath}/Games/NES/boot1.rom"
	[ -f "${misterpath}/Games/NES/boot2.rom" ] && [ "$(mount | grep -ic 'nes/boot2.rom')" == "1" ] && umount "${misterpath}/Games/NES/boot2.rom"
	[ -f "${misterpath}/Games/NES/boot3.rom" ] && [ "$(mount | grep -ic 'nes/boot3.rom')" == "1" ] && umount "${misterpath}/Games/NES/boot3.rom"
	if [ "${samquiet}" == "no" ]; then printf '%s\n' " Cleaned up mounts."; fi
}



# ======== CORE CONFIG ========
function init_data() {
	# Core to long name mappings
	declare -gA CORE_PRETTY=(
		["amiga"]="Commodore Amiga"
		["arcade"]="MiSTer Arcade"
		["atari2600"]="Atari 2600"
		["atari5200"]="Atari 5200"
		["atari7800"]="Atari 7800"
		["atarilynx"]="Atari Lynx"
		["c64"]="Commodore 64"
		["fds"]="Nintendo Disk System"
		["gb"]="Nintendo Game Boy"
		["gbc"]="Nintendo Game Boy Color"
		["gba"]="Nintendo Game Boy Advance"
		["genesis"]="Sega Genesis / Megadrive"
		["gg"]="Sega Game Gear"
		["megacd"]="Sega CD / Mega CD"
		["neogeo"]="SNK NeoGeo"
		["nes"]="Nintendo Entertainment System"
		["s32x"]="Sega 32x"
		["sms"]="Sega Master System"
		["snes"]="Super NES"
		["tgfx16"]="NEC TurboGrafx-16 "
		["tgfx16cd"]="NEC TurboGrafx-16 CD"
		["psx"]="Sony Playstation"
	)

	# Core to file extension mappings
	declare -glA CORE_EXT=(
		["amiga"]="hdf" 		#This is just a placeholder
		["arcade"]="mra"
		["atari2600"]="a26"     
		["atari5200"]="a52,car" 
		["atari7800"]="a78"     
		["atarilynx"]="lnx"		 
		["c64"]="crt,prg" 			# need to be tested "reu,tap,flt,rom,c1581"
		["fds"]="fds"
		["gb"]="gb"			 		
		["gbc"]="gbc"		 		
		["gba"]="gba"
		["genesis"]="md,gen" 		
		["gg"]="gg"
		["megacd"]="chd,cue"
		["neogeo"]="neo"
		["nes"]="nes"
		["s32x"]="32x"
		["sms"]="sms,sg"
		["snes"]="sfc,smc" 	 		# Should we include? "bin,bs"
		["tgfx16"]="pce,sgx"		
		["tgfx16cd"]="chd,cue"
		["psx"]="chd,cue,exe"
	)
	
	declare -glA FIRSTRUN=(
		["amiga"]="0"	
		["arcade"]="0"
		["atari2600"]="0"
		["atari5200"]="0"
		["atari7800"]="0"
		["atarilynx"]="0"
		["c64"]="0"
		["fds"]="0"
		["gb"]="0" 		
		["gbc"]="0" 		
		["gba"]="0"
		["genesis"]="0"
		["gg"]="0"
		["megacd"]="0"
		["neogeo"]="0"
		["nes"]="0"
		["s32x"]="0"
		["sms"]="0"
		["snes"]="0"	
		["tgfx16"]="0"
		["tgfx16cd"]="0"
		["psx"]="0"
	)

	# Core to path mappings
	declare -gA CORE_PATH=(
		["amiga"]="${amigapath}"
		["arcade"]="${arcadepath}"
		["atari2600"]="${atari2600path}"
		["atari5200"]="${atari5200path}"
		["atari7800"]="${atari7800path}"
		["atarilynx"]="${atarilynxpath}"				  
		["c64"]="${c64path}"
		["fds"]="${fdspath}"
		["gb"]="${gbpath}"
		["gbc"]="${gbcpath}"
		["gba"]="${gbapath}"
		["genesis"]="${genesispath}"
		["gg"]="${ggpath}"
		["megacd"]="${megacdpath}"
		["neogeo"]="${neogeopath}"
		["nes"]="${nespath}"
		["s32x"]="${s32xpath}"
		["sms"]="${smspath}"
		["snes"]="${snespath}"
		["tgfx16"]="${tgfx16path}"
		["tgfx16cd"]="${tgfx16cdpath}"
		["psx"]="${psxpath}"
	)

	# Core to extra path mappings
	declare -gA CORE_PATH_EXTRA=(
		["amiga"]="${amigapathextra}"
		["arcade"]="${arcadepathextra}"
		["atari2600"]="${atari2600pathextra}"
		["atari5200"]="${atari5200pathextra}"
		["atari7800"]="${atari7800pathextra}"
		["atarilynx"]="${atarilynxpathextra}"					   
		["c64"]="${c64pathextra}"
		["fds"]="${fdspathextra}"
		["gb"]="${gbpathextra}"
		["gbc"]="${gbcpathextra}"
		["gba"]="${gbapathextra}"
		["genesis"]="${genesispathextra}"
		["gg"]="${ggpathextra}"
		["megacd"]="${megacdpathextra}"
		["neogeo"]="${neogeopathextra}"
		["nes"]="${nespathextra}"
		["s32x"]="${s32xpathextra}"
		["sms"]="${smspathextra}"
		["snes"]="${snespathextra}"
		["tgfx16"]="${tgfx16pathextra}"
		["tgfx16cd"]="${tgfx16cdpathextra}"
		["psx"]="${psxpathextra}"
	)

	# Core to path mappings for rbf files
	declare -gA CORE_PATH_RBF=(
		["amiga"]="${amigapathrbf}"
		["arcade"]="${arcadepathrbf}"
		["atari2600"]="${atari2600pathrbf}"
		["atari5200"]="${atari5200pathrbf}"
		["atari7800"]="${atari7800pathrbf}"
		["atarilynx"]="${atarilynxpathrbf}"					 
		["c64"]="${c64pathrbf}"
		["fds"]="${fdspathrbf}"
		["gb"]="${gbpathrbf}"
		["gbc"]="${gbcpathrbf}"
		["gba"]="${gbapathrbf}"
		["genesis"]="${genesispathrbf}"
		["gg"]="${ggpathrbf}"
		["megacd"]="${megacdpathrbf}"
		["neogeo"]="${neogeopathrbf}"
		["nes"]="${nespathrbf}"
		["s32x"]="${s32xpathrbf}"
		["sms"]="${smspathrbf}"
		["snes"]="${snespathrbf}"
		["tgfx16"]="${tgfx16pathrbf}"
		["tgfx16cd"]="${tgfx16cdpathrbf}"
		["psx"]="${psxpathrbf}"
	)

	# Can this core use ZIPped ROMs
	declare -glA CORE_ZIPPED=(
		["amiga"]="No"
		["arcade"]="No"
		["atari2600"]="Yes"
		["atari5200"]="Yes"
		["atari7800"]="Yes"
		["atarilynx"]="Yes"			 
		["c64"]="Yes"
		["fds"]="Yes"
		["gb"]="Yes"
		["gbc"]="Yes"
		["gba"]="Yes"
		["genesis"]="Yes"
		["gg"]="Yes"
		["megacd"]="No"
		["neogeo"]="Yes"
		["nes"]="Yes"
		["s32x"]="Yes"
		["sms"]="Yes"
		["snes"]="Yes"
		["tgfx16"]="Yes"
		["tgfx16cd"]="No"
		["psx"]="No"
	)

	# Can this core skip Bios/Safety warning messages
	declare -glA CORE_SKIP=(
		["amiga"]="No"
		["arcade"]="No"
		["atari2600"]="No"
		["atari5200"]="No"
		["atari7800"]="No"
		["atarilynx"]="No"		
		["c64"]="No"
		["fds"]="Yes"
		["gb"]="No"
		["gbc"]="No"
		["gba"]="No"
		["genesis"]="No"
		["gg"]="No"
		["megacd"]="Yes"
		["neogeo"]="No"
		["nes"]="No"
		["s32x"]="No"
		["sms"]="No"
		["snes"]="No"
		["tgfx16"]="No"
		["tgfx16cd"]="Yes"
		["psx"]="No"
	)

	# Core to input maps mapping
	declare -gA CORE_LAUNCH=(
		["amiga"]="Minimig"
		["arcade"]="Arcade"
		["atari2600"]="ATARI7800"
		["atari5200"]="ATARI5200"
		["atari7800"]="ATARI7800"
		["atarilynx"]="AtariLynx"
		["c64"]="C64"
		["fds"]="NES"
		["gb"]="GAMEBOY"
		["gbc"]="GAMEBOY"
		["gba"]="GBA"
		["genesis"]="Genesis"
		["gg"]="SMS"
		["megacd"]="MegaCD"
		["neogeo"]="NEOGEO"
		["nes"]="NES"
		["s32x"]="S32X"
		["sms"]="SMS"
		["snes"]="SNES"
		["tgfx16"]="TGFX16"
		["tgfx16cd"]="TGFX16"
		["psx"]="PSX"
	)
	
	# TTY2OLED Core Pic mappings
	declare -gA TTY2OLED_PIC_NAME=(
		["amiga"]="Minimig"
		["arcade"]="Arcade"
		["atari2600"]="ATARI2600"
		["atari5200"]="ATARI5200"
		["atari7800"]="ATARI7800"
		["atarilynx"]="AtariLynx"
		["c64"]="C64"
		["fds"]="fds"
		["gb"]="GAMEBOY"
		["gbc"]="GAMEBOY"
		["gba"]="GBA"
		["genesis"]="Genesis"
		["gg"]="gamegear"
		["megacd"]="MegaCD"
		["neogeo"]="NEOGEO"
		["nes"]="NES"
		["s32x"]="S32X"
		["sms"]="SMS"
		["snes"]="SNES"
		["tgfx16"]="TGFX16"
		["tgfx16cd"]="TGFX16"
		["psx"]="PSX"
	)

	# MGL core name settings
	declare -gA MGL_CORE=(
		["amiga"]="minimig"
		["arcade"]="Arcade"
		["atari2600"]="ATARI7800"
		["atari5200"]="ATARI5200"
		["atari7800"]="ATARI7800"
		["atarilynx"]="AtariLynx"		   
		["c64"]="C64"
		["fds"]="NES"
		["gb"]="GAMEBOY"
		["gbc"]="GAMEBOY"
		["gba"]="GBA"
		["genesis"]="Genesis"
		["gg"]="SMS"
		["megacd"]="MegaCD"
		["neogeo"]="NEOGEO"
		["nes"]="NES"
		["s32x"]="S32X"
		["sms"]="SMS"
		["snes"]="SNES"
		["tgfx16"]="TurboGrafx16"
		["tgfx16cd"]="TurboGrafx16"
		["psx"]="PSX"
	)

	# MGL delay settings
	declare -giA MGL_DELAY=(
		["amiga"]="1"
		["arcade"]="2"
		["atari2600"]="1"
		["atari5200"]="1"
		["atari7800"]="1"
		["atarilynx"]="1"
		["c64"]="1"
		["fds"]="2"
		["gb"]="2"
		["gbc"]="2"
		["gba"]="2"
		["genesis"]="1"
		["gg"]="1"
		["megacd"]="1"
		["neogeo"]="1"
		["nes"]="2"
		["s32x"]="1"
		["sms"]="1"
		["snes"]="2"
		["tgfx16"]="1"
		["tgfx16cd"]="1"
		["psx"]="1"
	)

	# MGL index settings
	declare -giA MGL_INDEX=(
		["amiga"]="0"
		["arcade"]="0"
		["atari2600"]="0"
		["atari5200"]="1"
		["atari7800"]="1"
		["atarilynx"]="1"   
		["c64"]="1"
		["fds"]="0"
		["gb"]="0"
		["gbc"]="0"
		["gba"]="0"
		["genesis"]="0"
		["gg"]="2"
		["megacd"]="0"
		["neogeo"]="1"
		["nes"]="0"
		["s32x"]="0"
		["sms"]="1"
		["snes"]="0"
		["tgfx16"]="0"
		["tgfx16cd"]="0"
		["psx"]="1"
	)

	# MGL type settings
	declare -glA MGL_TYPE=(
		["amiga"]="f"
		["arcade"]="f"
		["atari2600"]="f"
		["atari5200"]="f"
		["atari7800"]="f"
		["atarilynx"]="f"
		["c64"]="f"
		["fds"]="f"
		["gb"]="f"
		["gbc"]="f"
		["gba"]="f"
		["genesis"]="f"
		["gg"]="f"
		["megacd"]="s"
		["neogeo"]="f"
		["nes"]="f"
		["s32x"]="f"
		["sms"]="f"
		["snes"]="f"
		["tgfx16"]="f"
		["tgfx16cd"]="s"
		["psx"]="s"
	)


	# NEOGEO to long name mappings English
	declare -gA NEOGEO_PRETTY_ENGLISH=(
		["3countb"]="3 Count Bout"
		["2020bb"]="2020 Super Baseball"
		["2020bba"]="2020 Super Baseball (set 2)"
		["2020bbh"]="2020 Super Baseball (set 3)"
		["abyssal"]="Abyssal Infants"
		["alpham2"]="Alpha Mission II"
		["alpham2p"]="Alpha Mission II (prototype)"
		["androdun"]="Andro Dunos"
		["aodk"]="Aggressors of Dark Kombat"
		["aof"]="Art of Fighting"
		["aof2"]="Art of Fighting 2"
		["aof2a"]="Art of Fighting 2 (NGH-056)"
		["aof3"]="Art of Fighting 3: The Path of the Warrior"
		["aof3k"]="Art of Fighting 3: The Path of the Warrior (Korean release)"
		["b2b"]="Bang Bang Busters"
		["badapple"]="Bad Apple Demo"
		["bakatono"]="Bakatonosama Mahjong Manyuuki"
		["bangbead"]="Bang Bead"
		["bjourney"]="Blue's Journey"
		["blazstar"]="Blazing Star"
		["breakers"]="Breakers"
		["breakrev"]="Breakers Revenge"
		["brningfh"]="Burning Fight (NGH-018, US)"
		["brningfp"]="Burning Fight (prototype, older)"
		["brnngfpa"]="Burning Fight (prototype, near final, ver 23.3, 910326)"
		["bstars"]="Baseball Stars Professional"
		["bstars2"]="Baseball Stars 2"
		["bstarsh"]="Baseball Stars Professional (NGH-002)"
		["burningf"]="Burning Fight"
		["burningfh"]="Burning Fight (NGH-018, US)"
		["burningfp"]="Burning Fight (prototype, older)"
		["burningfpa"]="Burning Fight (prototype, near final, ver 23.3, 910326)"
		["cabalng"]="Cabal"
		["columnsn"]="Columns"
		["cphd"]="Crouching Pony Hidden Dragon Demo"
		["crswd2bl"]="Crossed Swords 2 (CD conversion)"
		["crsword"]="Crossed Swords"
		["ct2k3sa"]="Crouching Tiger Hidden Dragon 2003 Super Plus (The King of Fighters 2001 bootleg)"
		["ctomaday"]="Captain Tomaday"
		["cyberlip"]="Cyber-Lip"
		["diggerma"]="Digger Man"
		["doubledr"]="Double Dragon"
		["eightman"]="Eight Man"
		["fatfursp"]="Fatal Fury Special"
		["fatfurspa"]="Fatal Fury Special (NGM-058 ~ NGH-058, set 2)"
		["fatfury1"]="Fatal Fury: King of Fighters"
		["fatfury2"]="Fatal Fury 2"
		["fatfury3"]="Fatal Fury 3: Road to the Final Victory"
		["fbfrenzy"]="Football Frenzy"
		["fghtfeva"]="Fight Fever (set 2)"
		["fightfev"]="Fight Fever"
		["fightfeva"]="Fight Fever (set 2)"
		["flipshot"]="Battle Flip Shot"
		["frogfest"]="Frog Feast"
		["froman2b"]="Idol Mahjong Final Romance 2 (CD conversion)"
		["fswords"]="Fighters Swords (Korean release of Samurai Shodown III)"
		["ftfurspa"]="Fatal Fury Special (NGM-058 ~ NGH-058, set 2)"
		["galaxyfg"]="Galaxy Fight: Universal Warriors"
		["ganryu"]="Ganryu"
		["garou"]="Garou: Mark of the Wolves"
		["garoubl"]="Garou: Mark of the Wolves (bootleg)"
		["garouh"]="Garou: Mark of the Wolves (earlier release)"
		["garoup"]="Garou: Mark of the Wolves (prototype)"
		["ghostlop"]="Ghostlop"
		["goalx3"]="Goal! Goal! Goal!"
		["gowcaizr"]="Voltage Fighter Gowcaizer"
		["gpilots"]="Ghost Pilots"
		["gpilotsh"]="Ghost Pilots (NGH-020, US)"
		["gururin"]="Gururin"
		["hyprnoid"]="Hypernoid"
		["irnclado"]="Ironclad (prototype, bootleg)"
		["ironclad"]="Ironclad"
		["ironclado"]="Ironclad (prototype, bootleg)"
		["irrmaze"]="The Irritating Maze"
		["janshin"]="Janshin Densetsu: Quest of Jongmaster"
		["joyjoy"]="Puzzled"
		["kabukikl"]="Far East of Eden: Kabuki Klash"
		["karnovr"]="Karnov's Revenge"
		["kf2k2mp"]="The King of Fighters 2002 Magic Plus (bootleg)"
		["kf2k2mp2"]="The King of Fighters 2002 Magic Plus II (bootleg)"
		["kf2k2pla"]="The King of Fighters 2002 Plus (bootleg set 2)"
		["kf2k2pls"]="The King of Fighters 2002 Plus (bootleg)"
		["kf2k5uni"]="The King of Fighters 10th Anniversary 2005 Unique (The King of Fighters 2002 bootleg)"
		["kf10thep"]="The King of Fighters 10th Anniversary Extra Plus (The King of Fighters 2002 bootleg)"
		["kizuna"]="Kizuna Encounter: Super Tag Battle"
		["kof2k4se"]="The King of Fighters Special Edition 2004 (The King of Fighters 2002 bootleg)"
		["kof94"]="The King of Fighters '94"
		["kof95"]="The King of Fighters '95"
		["kof95a"]="The King of Fighters '95 (NGM-084, alt board)"
		["kof95h"]="The King of Fighters '95 (NGH-084)"
		["kof96"]="The King of Fighters '96"
		["kof96h"]="The King of Fighters '96 (NGH-214)"
		["kof97"]="The King of Fighters '97"
		["kof97h"]="The King of Fighters '97 (NGH-2320)"
		["kof97k"]="The King of Fighters '97 (Korean release)"
		["kof97oro"]="The King of Fighters '97 Chongchu Jianghu Plus 2003 (bootleg)"
		["kof97pls"]="The King of Fighters '97 Plus (bootleg)"
		["kof98"]="The King of Fighters '98: The Slugfest"
		["kof98a"]="The King of Fighters '98: The Slugfest (NGM-2420, alt board)"
		["kof98h"]="The King of Fighters '98: The Slugfest (NGH-2420)"
		["kof98k"]="The King of Fighters '98: The Slugfest (Korean release)"
		["kof98ka"]="The King of Fighters '98: The Slugfest (Korean release, set 2)"
		["kof99"]="The King of Fighters '99: Millennium Battle"
		["kof99e"]="The King of Fighters '99: Millennium Battle (earlier release)"
		["kof99h"]="The King of Fighters '99: Millennium Battle (NGH-2510)"
		["kof99k"]="The King of Fighters '99: Millennium Battle (Korean release)"
		["kof99p"]="The King of Fighters '99: Millennium Battle (prototype)"
		["kof2000"]="The King of Fighters 2000"
		["kof2000n"]="The King of Fighters 2000"
		["kof2001"]="The King of Fighters 2001"
		["kof2001h"]="The King of Fighters 2001 (NGH-2621)"
		["kof2002"]="The King of Fighters 2002"
		["kof2002b"]="The King of Fighters 2002 (bootleg)"
		["kof2003"]="The King of Fighters 2003"
		["kof2003h"]="The King of Fighters 2003 (NGH-2710)"
		["kof2003ps2"]="The King of Fighters 2003 (PS2)"
		["kog"]="King of Gladiators (The King of Fighters '97 bootleg)"
		["kotm"]="King of the Monsters"
		["kotm2"]="King of the Monsters 2: The Next Thing"
		["kotm2p"]="King of the Monsters 2: The Next Thing (prototype)"
		["kotmh"]="King of the Monsters (set 2)"
		["lans2004"]="Lansquenet"
		["lastblad"]="The Last Blade"
		["lastbladh"]="The Last Blade (NGH-2340)"
		["lastbld2"]="The Last Blade 2"
		["lasthope"]="Last Hope"
		["lastsold"]="The Last Soldier"
		["lbowling"]="League Bowling"
		["legendos"]="Legend of Success Joe"
		["lresort"]="Last Resort"
		["lresortp"]="Last Resort (prototype)"
		["lstbladh"]="Last Blade (NGH-2340)"
		["magdrop2"]="Magical Drop II"
		["magdrop3"]="Magical Drop III"
		["maglord"]="Magician Lord"
		["maglordh"]="Magician Lord (NGH-005)"
		["mahretsu"]="Mahjong Kyo Retsuden"
		["marukodq"]="Chibi Marukochan Deluxe Quiz"
		["matrim"]="Power Instinct Matrimelee"
		["miexchng"]="Money Puzzle Exchanger"
		["minasan"]="Minasan no Okagesamadesu! Dai Sugoroku Taikai"
		["montest"]="Monitor Test ROM"
		["moshougi"]="Shougi no Tatsujin: Master of Syougi"
		["ms4plus"]="Metal Slug 4 Plus (bootleg)"
		["mslug"]="Metal Slug: Super Vehicle-001"
		["mslug2"]="Metal Slug 2: Super Vehicle-001/II"
		["mslug2t"]="Metal Slug 2 Turbo (hack)"
		["mslug3"]="Metal Slug 3"
		["mslug3b6"]="Metal Slug 6 (Metal Slug 3 bootleg)"
		["mslug3h"]="Metal Slug 3 (NGH-2560)"
		["mslug4"]="Metal Slug 4"
		["mslug4h"]="Metal Slug 4 (NGH-2630)"
		["mslug5"]="Metal Slug 5"
		["mslug5h"]="Metal Slug 5 (NGH-2680)"
		["mslug6"]="Metal Slug 6 (Metal Slug 3 bootleg)"
		["mslugx"]="Metal Slug X: Super Vehicle-001"
		["mutnat"]="Mutation Nation"
		["nam1975"]="NAM-1975"
		["nblktigr"]="Neo Black Tiger"
		["ncombat"]="Ninja Combat"
		["ncombath"]="Ninja Combat (NGH-009)"
		["ncommand"]="Ninja Commando"
		["neobombe"]="Neo Bomberman"
		["neocup98"]="Neo-Geo Cup 98: The Road to the Victory"
		["neodrift"]="Neo Drift Out: New Technology"
		["neofight"]="Neo Fight"
		["neomrdo"]="Neo Mr. Do!"
		["neothund"]="Neo Thunder"
		["neotris"]="NeoTRIS (free beta version)"
		["ninjamas"]="Ninja Master's"
		["nitd"]="Nightmare in the Dark"
		["nitdbl"]="Nightmare in the Dark (bootleg)"
		["nsmb"]="New Super Mario Bros."
		["overtop"]="OverTop"
		["panicbom"]="Panic Bomber"
		["pbbblenb"]="Puzzle Bobble (bootleg)"
		["pbobbl2n"]="Puzzle Bobble 2"
		["pbobblen"]="Puzzle Bobble"
		["pbobblenb"]="Puzzle Bobble (bootleg)"
		["pgoal"]="Pleasure Goal"
		["pnyaa"]="Pochi and Nyaa"
		["popbounc"]="Pop 'n Bounce"
		["preisle2"]="Prehistoric Isle 2"
		["pspikes2"]="Power Spikes II"
		["pulstar"]="Pulstar"
		["puzzldpr"]="Puzzle De Pon! R!"
		["puzzledp"]="Puzzle De Pon!"
		["quizdai2"]="Quiz Meitantei Neo & Geo: Quiz Daisousa Sen part 2"
		["quizdais"]="Quiz Daisousa Sen: The Last Count Down"
		["quizdask"]="Quiz Salibtamjeong: The Last Count Down (Korean localized Quiz Daisousa Sen)"
		["quizkof"]="Quiz King of Fighters"
		["quizkofk"]="Quiz King of Fighters (Korean release)"
		["ragnagrd"]="Ragnagard"
		["rbff1"]="Real Bout Fatal Fury"
		["rbff1a"]="Real Bout Fatal Fury (bug fix revision)"
		["rbff2"]="Real Bout Fatal Fury 2: The Newcomers"
		["rbff2h"]="Real Bout Fatal Fury 2: The Newcomers (NGH-2400)"
		["rbff2k"]="Real Bout Fatal Fury 2: The Newcomers (Korean release)"
		["rbffspck"]="Real Bout Fatal Fury Special (Korean release)"
		["rbffspec"]="Real Bout Fatal Fury Special"
		["rbffspeck"]="Real Bout Fatal Fury Special (Korean release)"
		["ridhero"]="Riding Hero"
		["ridheroh"]="Riding Hero (set 2)"
		["roboarma"]="Robo Army (NGM-032 ~ NGH-032)"
		["roboarmy"]="Robo Army"
		["roboarmya"]="Robo Army (NGM-032 ~ NGH-032)"
		["rotd"]="Rage of the Dragons"
		["rotdh"]="Rage of the Dragons (NGH-2640?)"
		["s1945p"]="Strikers 1945 Plus"
		["samsh5fe"]="Samurai Shodown V Special Final Edition"
		["samsh5pf"]="Samurai Shodown V Perfect"
		["samsh5sp"]="Samurai Shodown V Special"
		["samsh5sph"]="Samurai Shodown V Special (2nd release, less censored)"
		["samsh5spho"]="Samurai Shodown V Special (1st release, censored)"
		["samsho"]="Samurai Shodown"
		["samsho2"]="Samurai Shodown II"
		["samsho2k"]="Saulabi Spirits (Korean release of Samurai Shodown II)"
		["samsho2ka"]="Saulabi Spirits (Korean release of Samurai Shodown II, set 2)"
		["samsho3"]="Samurai Shodown III"
		["samsho3h"]="Samurai Shodown III (NGH-087)"
		["samsho4"]="Samurai Shodown IV: Amakusa's Revenge"
		["samsho4k"]="Pae Wang Jeon Seol: Legend of a Warrior"
		["samsho5"]="Samurai Shodown V"
		["samsho5b"]="Samurai Shodown V (bootleg)"
		["samsho5h"]="Samurai Shodown V (NGH-2700)"
		["samsho5x"]="Samurai Shodown V (XBOX version hack)"
		["samshoh"]="Samurai Shodown (NGH-045)"
		["savagere"]="Savage Reign"
		["sbp"]="Super Bubble Pop"
		["scbrawlh"]="Soccer Brawl (NGH-031)"
		["sdodgeb"]="Super Dodge Ball"
		["sengoku"]="Sengoku"
		["sengoku2"]="Sengoku 2"
		["sengoku3"]="Sengoku 3"
		["sengokuh"]="Sengoku (NGH-017, US)"
		["shcktroa"]="Shock Troopers (set 2)"
		["shocktr2"]="Shock Troopers: 2nd Squad"
		["shocktro"]="Shock Troopers"
		["shocktroa"]="Shock Troopers (set 2)"
		["smbng"]="New Super Mario Bros. Demo"
		["smsh5sph"]="Samurai Shodown V Special (2nd release, less censored)"
		["smsh5spo"]="Samurai Shodown V Special (1st release, censored)"
		["smsho2k2"]="Saulabi Spirits (Korean release of Samurai Shodown II, set 2)"
		["socbrawl"]="Soccer Brawl"
		["socbrawlh"]="Soccer Brawl (NGH-031)"
		["sonicwi2"]="Aero Fighters 2"
		["sonicwi3"]="Aero Fighters 3"
		["spinmast"]="Spinmaster"
		["ssideki"]="Super Sidekicks"
		["ssideki2"]="Super Sidekicks 2: The World Championship"
		["ssideki3"]="Super Sidekicks 3: The Next Glory"
		["ssideki4"]="The Ultimate 11: The SNK Football Championship"
		["stakwin"]="Stakes Winner"
		["stakwin2"]="Stakes Winner 2"
		["strhoop"]="Street Hoop / Street Slam"
		["superspy"]="The Super Spy"
		["svc"]="SNK vs. Capcom: SVC Chaos"
		["svccpru"]="SNK vs. Capcom Remix Ultra"
		["svcplus"]="SNK vs. Capcom Plus (bootleg)"
		["svcsplus"]="SNK vs. Capcom Super Plus (bootleg)"
		["teot"]="The Eye of Typhoon: Tsunami Edition"
		["tetrismn"]="Tetris"
		["tophuntr"]="Top Hunter: Roddy & Cathy"
		["tophuntrh"]="Top Hunter: Roddy & Cathy (NGH-046)"
		["totc"]="Treasure of the Caribbean"
		["tpgolf"]="Top Player's Golf"
		["tphuntrh"]="Top Hunter: Roddy & Cathy (NGH-046)"
		["trally"]="Thrash Rally"
		["turfmast"]="Neo Turf Masters"
		["twinspri"]="Twinkle Star Sprites"
		["tws96"]="Tecmo World Soccer '96"
		["twsoc96"]="Tecmo World Soccer '96"
		["viewpoin"]="Viewpoint"
		["wakuwak7"]="Waku Waku 7"
		["wh1"]="World Heroes"
		["wh1h"]="World Heroes (ALH-005)"
		["wh1ha"]="World Heroes (set 3)"
		["wh2"]="World Heroes 2"
		["wh2j"]="World Heroes 2 Jet"
		["whp"]="World Heroes Perfect"
		["wjammers"]="Windjammers"
		["wjammss"]="Windjammers Supersonic"
		["xenocrisis"]="Xeno Crisis"
		["zedblade"]="Zed Blade"
		["zintrckb"]="ZinTricK"
		["zintrkcd"]="ZinTricK (CD conversion)"
		["zupapa"]="Zupapa!"
	)

	# NEOGEO to long name mappings Japanese
	declare -gA NEOGEO_PRETTY_JAPANESE=(
		["3countb"]="Fire Suplex"
		["2020bb"]=""
		["2020bba"]=""
		["2020bbh"]=""
		["abyssal"]=""
		["alpham2"]="ASO II: Last Guardian"
		["alpham2p"]="ASO II: Last Guardian (prototype)"
		["androdun"]=""
		["aodk"]="Tsuukai GANGAN Koushinkyoku"
		["aof"]="Ryuuko no Ken"
		["aof2"]="Ryuuko no Ken 2"
		["aof2a"]="Ryuuko no Ken 2 (NGH-056)"
		["aof3"]="Art of Fighting: Ryuuko no Ken Gaiden"
		["aof3k"]=""
		["b2b"]=""
		["badapple"]=""
		["bakatono"]=""
		["bangbead"]=""
		["bjourney"]="Raguy"
		["blazstar"]=""
		["breakers"]=""
		["breakrev"]=""
		["brningfh"]=""
		["brningfp"]=""
		["brnngfpa"]=""
		["bstars"]=""
		["bstars2"]=""
		["bstarsh"]=""
		["burningf"]=""
		["burningfh"]=""
		["burningfp"]=""
		["burningfpa"]=""
		["cabalng"]=""
		["columnsn"]=""
		["cphd"]=""
		["crswd2bl"]=""
		["crsword"]=""
		["ct2k3sa"]=""
		["ctomaday"]=""
		["cyberlip"]=""
		["diggerma"]=""
		["doubledr"]=""
		["eightman"]=""
		["fatfursp"]="Garou Densetsu Special"
		["fatfurspa"]="Garou Densetsu Special (NGM-058 ~ NGH-058, set 2)"
		["fatfury1"]="Garou Densetsu: Shukumei no Tatakai"
		["fatfury2"]="Garou Densetsu 2: Arata-naru Tatakai"
		["fatfury3"]="Garou Densetsu 3: Haruka-naru Tatakai"
		["fbfrenzy"]=""
		["fghtfeva"]="Wang Jung Wang (set 2)"
		["fightfev"]="Wang Jung Wang"
		["fightfeva"]="Wang Jung Wang (set 2)"
		["flipshot"]=""
		["frogfest"]=""
		["froman2b"]=""
		["fswords"]=""
		["ftfurspa"]="Garou Densetsu Special (NGM-058 ~ NGH-058, set 2)"
		["galaxyfg"]=""
		["ganryu"]="Musashi Ganryuki"
		["garou"]=""
		["garoubl"]=""
		["garouh"]=""
		["garoup"]=""
		["ghostlop"]=""
		["goalx3"]=""
		["gowcaizr"]="Choujin Gakuen Gowcaizer"
		["gpilots"]=""
		["gpilotsh"]=""
		["gururin"]=""
		["hyprnoid"]=""
		["irnclado"]="Choutetsu Brikin'ger (prototype, bootleg)"
		["ironclad"]="Choutetsu Brikin'ger"
		["ironclado"]="Choutetsu Brikin'ger (prototype, bootleg)"
		["irrmaze"]="Ultra Denryu Iraira Bou"
		["janshin"]=""
		["joyjoy"]="Joy Joy Kid"
		["kabukikl"]="Tengai Makyou: Shin Den"
		["karnovr"]="Fighter's History Dynamite"
		["kf2k2mp"]=""
		["kf2k2mp2"]=""
		["kf2k2pla"]=""
		["kf2k2pls"]=""
		["kf2k5uni"]=""
		["kf10thep"]=""
		["kizuna"]="Fu'un Super Tag Battle"
		["kof2k4se"]=""
		["kof94"]=""
		["kof95"]=""
		["kof95a"]=""
		["kof95h"]=""
		["kof96"]=""
		["kof96h"]=""
		["kof97"]=""
		["kof97h"]=""
		["kof97k"]=""
		["kof97oro"]=""
		["kof97pls"]=""
		["kof98"]="King of Fighters '98: Dream Match Never Ends"
		["kof98a"]="King of Fighters '98: Dream Match Never Ends (NGM-2420, alt board)"
		["kof98h"]="King of Fighters '98: Dream Match Never Ends (NGH-2420)"
		["kof98k"]=""
		["kof98ka"]=""
		["kof99"]=""
		["kof99e"]=""
		["kof99h"]=""
		["kof99k"]=""
		["kof99p"]=""
		["kof2000"]=""
		["kof2000n"]=""
		["kof2001"]=""
		["kof2001h"]=""
		["kof2002"]=""
		["kof2002b"]=""
		["kof2003"]=""
		["kof2003h"]=""
		["kof2003ps2"]=""
		["kog"]=""
		["kotm"]=""
		["kotm2"]=""
		["kotm2p"]=""
		["kotmh"]=""
		["lans2004"]=""
		["lastblad"]="Bakumatsu Roman: Gekka no Kenshi"
		["lastbladh"]="Bakumatsu Roman: Gekka no Kenshi (NGH-2340)"
		["lastbld2"]="Bakumatsu Roman: Dai Ni Maku Gekka no Kenshi"
		["lasthope"]=""
		["lastsold"]=""
		["lbowling"]=""
		["legendos"]="Ashita no Joe Densetsu"
		["lresort"]=""
		["lresortp"]=""
		["lstbladh"]="Bakumatsu Roman: Gekka no Kenshi (NGH-2340)"
		["magdrop2"]="Magical Drop 2"
		["magdrop3"]=""
		["maglord"]=""
		["maglordh"]=""
		["mahretsu"]=""
		["marukodq"]=""
		["matrim"]="Shin Goketsuji Ichizoku: Tokon Matrimelee"
		["miexchng"]="Money Idol Exchanger"
		["minasan"]=""
		["montest"]=""
		["moshougi"]=""
		["ms4plus"]=""
		["mslug"]=""
		["mslug2"]=""
		["mslug2t"]=""
		["mslug3"]=""
		["mslug3b6"]=""
		["mslug3h"]=""
		["mslug4"]=""
		["mslug4h"]=""
		["mslug5"]=""
		["mslug5h"]=""
		["mslug6"]=""
		["mslugx"]=""
		["mutnat"]=""
		["nam1975"]=""
		["nblktigr"]=""
		["ncombat"]=""
		["ncombath"]=""
		["ncommand"]=""
		["neobombe"]=""
		["neocup98"]=""
		["neodrift"]=""
		["neofight"]=""
		["neomrdo"]=""
		["neothund"]=""
		["neotris"]=""
		["ninjamas"]="Haoh-ninpo-cho"
		["nitd"]=""
		["nitdbl"]=""
		["nsmb"]=""
		["overtop"]=""
		["panicbom"]=""
		["pbbblenb"]="Bust-A-Move (bootleg)"
		["pbobbl2n"]="Bust-A-Move Again"
		["pbobblen"]="Bust-A-Move"
		["pbobblenb"]="Bust-A-Move (bootleg)"
		["pgoal"]=""
		["pnyaa"]="Pochi to Nyaa"
		["popbounc"]="Gapporin"
		["preisle2"]=""
		["pspikes2"]=""
		["pulstar"]=""
		["puzzldpr"]=""
		["puzzledp"]=""
		["quizdai2"]=""
		["quizdais"]=""
		["quizdask"]=""
		["quizkof"]=""
		["quizkofk"]=""
		["ragnagrd"]="Shin-Oh-Ken"
		["rbff1"]="Real Bout Garou Densetsu"
		["rbff1a"]="Real Bout Garou Densetsu (bug fix revision)"
		["rbff2"]="Real Bout Garou Densetsu 2: The Newcomers"
		["rbff2h"]="Real Bout Garou Densetsu 2: The Newcomers (NGH-2400)"
		["rbff2k"]=""
		["rbffspck"]=""
		["rbffspec"]="Real Bout Garou Densetsu Special"
		["rbffspeck"]=""
		["ridhero"]=""
		["ridheroh"]=""
		["roboarma"]=""
		["roboarmy"]=""
		["roboarmya"]=""
		["rotd"]=""
		["rotdh"]=""
		["s1945p"]=""
		["samsh5fe"]="Samurai Shodown Zero Special Final Edition"
		["samsh5pf"]="Samurai Spirits Zero Perfect"
		["samsh5sp"]="Samurai Spirits Zero Special"
		["samsh5sph"]="Samurai Spirits Zero Special (2nd release, less censored)"
		["samsh5spho"]="Samurai Spirits Zero Special (1st release, censored)"
		["samsho"]="Samurai Spirits"
		["samsho2"]="Shin Samurai Spirits: Haohmaru Jigokuhen"
		["samsho2k"]=""
		["samsho2ka"]=""
		["samsho3"]="Samurai Spirits: Zankurou Musouken"
		["samsho3h"]="Samurai Spirits: Zankurou Musouken (NGH-087)"
		["samsho4"]="Samurai Spirits: Amakusa Kourin"
		["samsho4k"]=""
		["samsho5"]="Samurai Spirits Zero"
		["samsho5b"]="Samurai Spirits Zero (bootleg)"
		["samsho5h"]="Samurai Spirits Zero (NGH-2700)"
		["samsho5x"]="Samurai Spirits Zero (XBOX version hack)"
		["samshoh"]="Samurai Spirits (NGH-045)"
		["savagere"]="Fu'un Mokushiroku: Kakutou Sousei"
		["sbp"]=""
		["scbrawlh"]=""
		["sdodgeb"]="Kunio no Nekketsu Toukyuu Densetsu"
		["sengoku"]="Sengoku Denshou"
		["sengoku2"]="Sengoku Denshou 2"
		["sengoku3"]="Sengoku Denshou 2001"
		["sengokuh"]="Sengoku Denshou (NGH-017, US)"
		["shcktroa"]=""
		["shocktr2"]=""
		["shocktro"]=""
		["shocktroa"]=""
		["smbng"]=""
		["smsh5sph"]="Samurai Spirits Zero Special (2nd release, less censored)"
		["smsh5spo"]="Samurai Spirits Zero Special (1st release, censored)"
		["smsho2k2"]=""
		["socbrawl"]=""
		["socbrawlh"]=""
		["sonicwi2"]="Sonic Wings 2"
		["sonicwi3"]="Sonic Wings 3"
		["spinmast"]="Miracle Adventure"
		["ssideki"]="Tokuten Ou"
		["ssideki2"]="Tokuten Ou 2: Real Fight Football"
		["ssideki3"]="Tokuten Ou 3: Eikou e no Chousen"
		["ssideki4"]="Tokuten Ou: Honoo no Libero"
		["stakwin"]="Stakes Winner: GI Kinzen Seiha e no Michi"
		["stakwin2"]=""
		["strhoop"]="Dunk Dream"
		["superspy"]=""
		["svc"]=""
		["svccpru"]=""
		["svcplus"]=""
		["svcsplus"]=""
		["teot"]=""
		["tetrismn"]=""
		["tophuntr"]=""
		["tophuntrh"]=""
		["totc"]=""
		["tpgolf"]=""
		["tphuntrh"]=""
		["trally"]=""
		["turfmast"]="Big Tournament Golf"
		["twinspri"]=""
		["tws96"]=""
		["twsoc96"]=""
		["viewpoin"]=""
		["wakuwak7"]=""
		["wh1"]=""
		["wh1h"]=""
		["wh1ha"]=""
		["wh2"]=""
		["wh2j"]=""
		["whp"]=""
		["wjammers"]="Flying Power Disc"
		["wjammss"]=""
		["xenocrisis"]=""
		["zedblade"]="Operation Ragnarok"
		["zintrckb"]="Oshidashi Zentrix"
		["zintrkcd"]="Oshidashi Zentrix (CD conversion)"
		["zupapa"]=""
	)

}

# ======== DEBUG OUTPUT =========
function debug_output() {
	echo " ********************************************************************************"
	# ======== GLOBAL VARIABLES =========
	echo " mrsampath: ${mrsampath}"
	echo " misterpath: ${misterpath}"
	echo " sampid: ${sampid}"
	echo " samprocess: ${samprocess}"
	echo ""
	# ======== LOCAL VARIABLES ========
	echo " commandline: ${@}"
	echo " repository_url: ${repository_url}"
	echo " branch: ${branch}"

	echo ""
	echo " gametimer: ${gametimer}"
	echo " corelist: ${corelist}"
	echo " usezip: ${usezip}"

	echo " mralist: ${mralist_tmp}"
	echo " listenmouse: ${listenmouse}"
	echo " listenkeyboard: ${listenkeyboard}"
	echo " listenjoy: ${listenjoy}"
	echo ""
	echo " arcadepath: ${arcadepath}"
	echo " gbapath: ${gbapath}"
	echo " genesispath: ${genesispath}"
	echo " megacdpath: ${megacdpath}"
	echo " neogeopath: ${neogeopath}"
	echo " nespath: ${nespath}"
	echo " snespath: ${snespath}"
	echo " tgfx16path: ${tgfx16path}"
	echo " tgfx16cdpath: ${tgfx16cdpath}"
	echo ""
	echo " gbalist: ${gbalist}"
	echo " genesislist: ${genesislist}"
	echo " megacdlist: ${megacdlist}"
	echo " neogeolist: ${neogeolist}"
	echo " neslist: ${neslist}"
	echo " sneslist: ${sneslist}"
	echo " tgfx16list: ${tgfx16list}"
	echo " tgfx16cdlist: ${tgfx16cdlist}"
	echo ""
	echo " arcadeexclude: ${arcadeexclude[@]}"
	echo " gbaexclude: ${gbaexclude[@]}"
	echo " genesisexclude: ${genesisexclude[@]}"
	echo " megacdexclude: ${megacdexclude[@]}"
	echo " neogeoexclude: ${neogeoexclude[@]}"
	echo " nesexclude: ${nesexclude[@]}"
	echo " snesexclude: ${snesexclude[@]}"
	echo " tgfx16exclude: ${tgfx16exclude[@]}"
	echo " tgfx16cdexclude: ${tgfx16cdexclude[@]}"
	echo " ********************************************************************************"
	read -p " Continuing in 5 seconds or press any key..." -n 1 -t 5 -r -s
}
# ========= PARSE INI =========

# Read INI
function read_samini() {
	if [ -f "${misterpath}/Scripts/MiSTer_SAM.ini" ]; then
		source "${misterpath}/Scripts/MiSTer_SAM.ini"
		# Remove trailing slash from paths
		for var in $(grep "^[^#;]" "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "path=" | cut -f1 -d"="); do
			declare -g ${var}="${!var%/}"
		done
		for var in $(grep "^[^#;]" "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "pathextra=" | cut -f1 -d"="); do
			declare -g ${var}="${!var%/}"
		done
		for var in $(grep "^[^#;]" "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "pathrbf=" | cut -f1 -d"="); do
			declare -g ${var}="${!var%/}"
		done
		
	else
		sam_update autoconfig
	fi

	# Setup corelist
	corelist="$(echo ${corelist} | tr ',' ' ' | tr -s ' ')"
	corelistall="$(echo ${corelistall} | tr ',' ' ' | tr -s ' ')"

	# Create array of coreexclude list names
	declare -a coreexcludelist
	for core in ${corelistall}; do
		coreexcludelist+=("${core}exclude")
	done

	# Iterate through coreexclude lists and make list into array
	for excludelist in ${coreexcludelist[@]}; do
		readarray -t ${excludelist} <<<${!excludelist}
	done

	# Create folder and file exclusion list
	folderex=$(for f in "${exclude[@]}"; do echo "-o -iname *$f*"; done)
	fileex=$(for f in "${exclude[@]}"; do echo "-and -not -iname *$f*"; done)

	# Create file and folder exclusion list for zips. Always exclude BIOS files as a default
	zipex=$(printf "%s," "${exclude[@]}" && echo "bios")
}


# ======== SAM MENU ========
function sam_premenu() {
	echo "+---------------------------+"
	echo "| MiSTer Super Attract Mode |"
	echo "+---------------------------+"
	echo " SAM Configuration:"
	if [ $(grep -ic "mister_sam" "${userstartup}") != "0" ]; then
		echo " -SAM autoplay ENABLED"
	else
		echo " -SAM autoplay DISABLED"
	fi
	echo " -Start after ${samtimeout} sec. idle"
	echo " -Start only on the menu: ${menuonly^}"
	echo " -Show each game for ${gametimer} sec."
	echo ""
	echo " Press UP to open menu"
	echo " Press DOWN to start SAM"
	echo ""
	echo " Or wait for"
	echo " auto-configuration"
	echo ""

	for i in {5..1}; do
		echo -ne " Updating SAM in ${i}...\033[0K\r"
		premenu="Default"
		read -r -s -N 1 -t 1 key
		if [[ "${key}" == "A" ]]; then
			premenu="Menu"
			break
		elif [[ "${key}" == "B" ]]; then
			premenu="Start"
			break
		elif [[ "${key}" == "C" ]]; then
			premenu="Default"
			break
		fi
	done
	parse_cmd ${premenu}
}

function sam_menu() {
	inmenu=1
	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Exit" \
		--backtitle "Super Attract Mode" --title "[ Main Menu ]" \
		--menu "Use the arrow keys and enter \nor the d-pad and A button" 0 0 0 \
		Start "Start SAM now" \
		Startmonitor "Start SAM now and monitor (ssh)" \
		Skip "Skip game" \
		Stop "Stop SAM" \
		Update "Update SAM to latest" \
		'' "" \
		Single "Single core selection" \
		Include "Single category selection" \
		Exclude "Exclude categories" \
		Gamemode "Game roulette" \
		BGM "Background Music Player" \
		Config "Configure INI Settings" \
		Favorite "Copy current game to _Favorites folder" \
		Gamelists "Game Lists - Create or Delete" \
		Reset "Reset or uninstall SAM" \
		Autoplay "Autoplay Configuration" 2>"/tmp/.SAMmenu"
	
	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear
	
	if [ "$opt" != "0" ]; then
		exit
	else 
		parse_cmd ${menuresponse}
	fi

}

function sam_singlemenu() {
	declare -a menulist=()
	for core in ${corelistall}; do
		menulist+=("${core^^}")
		menulist+=("${CORE_PRETTY[${core}]} games only")
	done

	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ Single System Select ]" \
		--menu "Which system?" 0 0 0 \
		"${menulist[@]}" 2>"/tmp/.SAMmenu"
	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear
	
	if [ "$opt" != "0" ]; then
		sam_menu
	else 
		parse_cmd ${menuresponse}
	fi

}

function sam_resetmenu() {
	inmenu=1
	dialog --clear --no-cancel --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ Reset ]" \
		--menu "Select an option" 0 0 0 \
		Deleteall "Reset/Delete all files" \
		Default "Reinstall SAM and enable Autostart" \
		Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "${samquiet}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_gamelistmenu() {
	inmenu=1
	dialog --clear --no-cancel --ascii-lines --colors \
		--backtitle "Super Attract Mode" --title "[ GAMELIST MENU ]" \
		--msgbox "Game Lists contain filenames that SAM can play for each core. \n\nThey get created automatically when SAM plays games. Here you can create or delete those lists." 0 0
	dialog --clear --no-cancel --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ GAMELIST MENU ]" \
		--menu "Select an option" 0 0 0 \
		CreateGL "Create all Game Lists" \
		DeleteGL "Delete all Game Lists" \
		Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "${samquiet}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_autoplaymenu() {
	dialog --clear --no-cancel --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ Configure Autoplay ]" \
		--menu "Select an option" 0 0 0 \
		Enable "Enable Autoplay" \
		Disable "Disable Autoplay" \
		Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")

	clear
	if [ "${samquiet}" == "no" ]; then echo " menuresponse: ${menuresponse}"; fi
	parse_cmd ${menuresponse}
}

function sam_configmenu() {
	dialog --clear --ascii-lines --no-cancel \
		--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
		--msgbox "Here you can configure the INI settings for SAM.\n\nUse TAB to switch between editing, the OK and Cancel buttons." 0 0

	dialog --clear --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
		--editbox "${misterpath}/Scripts/MiSTer_SAM.ini" 0 0 2>"/tmp/.SAMmenu"

	if [ -s "/tmp/.SAMmenu" ] && [ "$(diff -wq "/tmp/.SAMmenu" "${misterpath}/Scripts/MiSTer_SAM.ini")" ]; then
		cp -f "/tmp/.SAMmenu" "${misterpath}/Scripts/MiSTer_SAM.ini"
		dialog --clear --ascii-lines --no-cancel \
			--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
			--msgbox "Changes saved!" 0 0
	fi

	parse_cmd menu
}

function sam_gamemodemenu() {
	dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ GAME ROULETTE ]" \
		--msgbox "In Game Roulette mode SAM selects games for you. \n\nYou have a pre-defined amount of time to play this game, then SAM will move on to play the next game. \n\nPlease do a cold reboot when done playing." 0 0
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ GAME ROULETTE ]" \
		--menu "Select an option" 0 0 0 \
		Roulette2 "Play a random game for 2 minutes. " \
		Roulette5 "Play a random game for 5 minutes. " \
		Roulette10 "Play a random game for 10 minutes. " \
		Roulette15 "Play a random game for 15 minutes. " \
		Roulette20 "Play a random game for 20 minutes. " \
		Roulette25 "Play a random game for 25 minutes. " \
		Roulette30 "Play a random game for 30 minutes. " \
		Roulettetimer "Play a random game for ${roulettetimer} secs (roulettetimer in MiSTer_SAM.ini). " 2>"/tmp/.SAMmenu"	
	
		opt=$?
		menuresponse=$(<"/tmp/.SAMmenu")
		
		if [ "$opt" != "0" ]; then
			sam_menu
		elif [ "${menuresponse}" == "Roulettetimer" ]; then
			gametimer=${roulettetimer}
			kill_all_sams
			sam_cleanup
			#tty_init
			checkgl
			mute=no
			listenmouse="No"
			listenkeyboard="No"
			listenjoy="No"
			loop_core	
		else
			timemin=${menuresponse//Roulette/}
			gametimer=$((timemin*60))
			kill_all_sams
			sam_cleanup
			#tty_init
			checkgl
			mute=no
			listenmouse="No"
			listenkeyboard="No"${ttydevice}
			listenjoy="No"
			loop_core
		fi
}

function samedit_include() {
	dialog --clear --no-cancel --ascii-lines --colors \
		--backtitle "Super Attract Mode" --title "[ CATEGORY SELECTION ]" \
		--msgbox "Play games from only one category.\n\n\Z1Please use Everdrive packs for this mode. \Zn \n\nSome categories (like country selection) will probably work with some other rompacks as well. \n\nMake sure you have game lists created for this mode." 0 0
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ CATEGORY SELECTION ]" \
		--menu "Only play games from the following categories" 0 0 0 \
		''"("'usa'")"'' "Only USA Games" \
		''"("'japan'")"'' "Only Japanese Games" \
		''"("'europe'")"'' "Only Europe games" \
		'shoot '"'"'em' "Only Shoot 'Em Ups" \
		'beat '"'"'em' "Only Beat 'Em Ups" \
		'role playing' "Only Role Playing Games" \
		pinball "Only Pinball Games" \
		platformers "Only Platformers" \
		'genre/fight' "Only Fighting Games" \
		trivia "Only Trivia Games" \
		sports "Only Sport Games" \
		racing "Only Racing Games" \
		hacks "Only Hacks" \
		translations "Only Translated Games" \
		homebrew "Only Homebrew" 2>"/tmp/.SAMmenu"

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "$opt" != "0" ]; then
		sam_menu
	else
		echo "Please wait... getting things ready."
		declare -a corelist=()
		declare -a gamelists=()
		categ="${menuresponse}"
		# echo "${menuresponse}"
		# Delete all temporary Game lists
		if compgen -G "${gamelistpathtmp}/*_gamelist.txt" >/dev/null; then
			rm ${gamelistpathtmp}/*_gamelist.txt
		fi
		gamelists=($(find "${gamelistpath}" -name "*_gamelist.txt"))

		# echo ${gamelists[@]}
		for list in ${gamelists[@]}; do
			listfile=$(basename ${list})
			# awk -v category="$categ" 'tolower($0) ~ category' "${list}" > "${gamelistpathtmp}/${listfile}"
			grep -i "${categ}" "${list}" >"${tmpfile}"
			awk -F'/' '!seen[$NF]++' "${tmpfile}" >"${gamelistpathtmp}/${listfile}"
			[[ -s "${gamelistpathtmp}/${listfile}" ]] || rm "${gamelistpathtmp}/${listfile}"
		done

		corelist=$(find "${gamelistpathtmp}" -name "*_gamelist.txt" -exec basename \{} \; | cut -d '_' -f 1)

		dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ CATEGORY SELECTION ]" \
			--msgbox "SAM will start now and only play games from the '${categ^^}' category.\n\nOn cold reboot, SAM will get reset automatically to play all games again. " 0 0
		kill_all_sams
		sam_prep
		#tty_init
		checkgl
		loop_core
	fi

}

function samedit_excltags() {
	excludetags="${gamelistpath}/.excludetags"
	
	function process_tag() {
		for core in ${corelist}; do
			[[ -f "${gamelistpathtmp}/${core}_gamelist.txt" ]] && rm "${gamelistpathtmp}/${core}_gamelist.txt"
			if [ "${gamelistpath}/${core}_gamelist.txt" ]; then
				grep -i "$categ" "${gamelistpath}/${core}_gamelist.txt" >>"${gamelistpath}/${core}_gamelist_exclude.txt"
			else
				grep -i "$categ" "${gamelistpath}/${core}_gamelist.txt" >"${gamelistpath}/${core}_gamelist_exclude.txt"
			fi
		done
	}
	
	if [ -f "${excludetags}" ]; then
		dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
		--msgbox "Currently excluded tags: \n\n$(cat "${excludetags}")" 0 0
	else
		dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
		--msgbox "Exclude hacks, prototypes, homebrew or other game categories you don't want SAM to show.\n\n" 0 0
	fi 

	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Done" \
		--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
		--menu "Which tags do you want to exclude?" 0 0 0 \
		Beta "Beta Games" \
		Hack "Hacks" \
		Homebrew "Homebrew" \
		Prototype "Prototypes"  \
		Unlicensed "Unlicensed Games" \
		Translations "Translated Games" \
		USA "USA" \
		Japan "Japan" \
		Europe "Europe" \
		'' "Reset Exclusion Lists" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	categ="${menuresponse}"
	
	if [ "$opt" != "0" ]; then
		sam_menu
	else
		echo " Please wait... creating exclusion lists."
		if [ ! -z ${categ} ]; then
			if [ ! -s "${excludetags}" ]; then
				echo "${categ} " > "${excludetags}"
				process_tag
			else
				# Check if tag is already excluded
				if [ "$(grep -i "${categ}" "${excludetags}")" ]; then
					dialog --clear --no-cancel --ascii-lines \
					--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
					--msgbox "${categ} has already been excluded. \n\n" 0 0
				else
					echo "${categ} " >> "${excludetags}"
					# TO DO: What if we don't have gamelists
					process_tag
				fi
			fi
		else
			for core in ${corelist}; do
				rm "${gamelistpath}/${core}_gamelist_exclude.txt" 2>/dev/null
				rm "${excludetags}" 2>/dev/null
			done
			dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
			--msgbox "All exclusion filters have been removed. \n\n" 0 0
			sam_menu
		fi
		find "${gamelistpath}" -name "*_gamelist_exclude.txt" -size 0 -print0 | xargs -0 rm
		samedit_excltags
	fi
	
}

function samedit_excltags_old() {
	# Looks better but doesn't work with gamepad
	dialog --title "[ EXCLUDE CATEGORY SELECTION ]" --ascii-lines --checklist \
		"Which tags do you want to exclude?" 0 0 0 \
		"Beta" "" OFF \
		"Hack" "" OFF \
		"Homebrew" "" OFF \
		"Prototypes" "" OFF \
		"Unlicensed" "" OFF \
		"Translations" "" OFF \
		"USA" "" OFF \
		"Japan" "" OFF \
		"Europe" "" OFF \
		"Australia" "" OFF \
		"Brazil" "" OFF \
		"China" "" OFF \
		"France" "" OFF \
		"Germany" "" OFF "Italy" "" OFF \
		"Korea" "" OFF \
		"Spain" "" OFF \
		"Sweden" "" OFF 2>"/tmp/.SAMmenu"

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")

	if [ "$opt" != "0" ]; then
		sam_menu
	else
		echo " Please wait... creating exclusion lists."
		categ="$(echo ${menuresponse} | tr ' ' '|')"
		if [ ! -z ${categ} ]; then
			# TO DO: What if we don't have gamelists
			for core in ${corelist}; do
				[[ -f "${gamelistpathtmp}/${core}_gamelist.txt" ]] && rm "${gamelistpathtmp}/${core}_gamelist.txt"
				# Find out how to do this with grep, might be faster
				awk -v category="$categ" 'BEGIN {IGNORECASE = 1}  $0 ~ category' "${gamelistpath}/${core}_gamelist.txt" >"${gamelistpath}/${core}_gamelist_exclude.txt"
			done
		else
			for core in ${corelist}; do
				rm "${gamelistpath}/${core}_gamelist_exclude.txt"
			done
		fi
		find "${gamelistpath}" -name "*_gamelist_exclude.txt" -size 0 -print0 | xargs -0 rm
		samedit_taginfo
	fi

}

function sam_bgmmenu() {
	dialog --clear --no-cancel --ascii-lines \
	--backtitle "Super Attract Mode" --title "[ BACKGROUND MUSIC ENABLER ]" \
	--msgbox "While SAM is shuffling games, play some music.\n\nThis installs wizzomafizzo's BGM script to play Background music in SAM.\n\nWe'll drop one playlist in the music folder (80s.pls) as a default playlist. You can customize this later or to your liking by dropping mp3's or pls files in /media/fat/music folder." 0 0
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ BACKGROUND MUSIC ENABLER ]" \
		--menu "Select from the following options?" 0 0 0 \
		Enablebgm "Enable BGM for SAM" \
		Disablebgm "Disable BGM for SAM" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	if [ "$opt" != "0" ]; then
		sam_menu
	else
		if [[ "${menuresponse,,}" == "enablebgm" ]]; then
			if [ ! -f "/media/fat/Scripts/bgm.sh" ]; then
				echo " Installing BGM to Scripts folder"
				repository_url="https://github.com/wizzomafizzo/MiSTer_BGM"
				get_samstuff bgm.sh /tmp
				mv --force /tmp/bgm.sh /media/fat/Scripts/
			else
				echo " BGM script is installed already. Updating just in case..."
				/media/fat/Scripts/bgm.sh stop &>/dev/null
				repository_url="https://github.com/wizzomafizzo/MiSTer_BGM"
				get_samstuff bgm.sh /tmp
				mv --force /tmp/bgm.sh /media/fat/Scripts/
				echo " Resetting BGM now."
			fi
			echo " Updating MiSTer_SAM.ini to use Mute=Core"
			sed -i '/mute=/c\mute=Core' /media/fat/Scripts/MiSTer_SAM.ini
			/media/fat/Scripts/bgm.sh
			sync
			repository_url="https://github.com/mrchrisster/MiSTer_SAM"
			get_samstuff Media/80s.pls /media/fat/music
			[[ ! $(grep -i "bgm" /media/fat/Scripts/MiSTer_SAM.ini) ]] && echo "bgm=Yes" >> /media/fat/Scripts/MiSTer_SAM.ini
			sed -i '/bgm=/c\bgm=Yes' /media/fat/Scripts/MiSTer_SAM.ini
			echo " All Done. Starting SAM now."
			/media/fat/Scripts/MiSTer_SAM_on.sh start

		elif [[ "${menuresponse,,}" == "disablebgm" ]]; then
			echo " Uninstalling BGM, please wait..."
			[[ -e /media/fat/Scripts/bgm.sh ]] && /media/fat/Scripts/bgm.sh stop
			[[ -e /media/fat/Scripts/bgm.sh ]] && rm /media/fat/Scripts/bgm.sh
			[[ -e /media/fat/music/bgm.ini ]] && rm /media/fat/music/bgm.ini
			sed -i '/bgm.sh/d' ${userstartup}
			sed -i '/Startup BGM/d' ${userstartup}
			sed -i '/bgm=/c\bgm=No' /media/fat/Scripts/MiSTer_SAM.ini
			echo " Done."
		fi
	fi
}




function parse_cmd() {
	if [ ${#} -gt 2 ]; then # We don't accept more than 2 parameters
		sam_help
	elif [ ${#} -eq 0 ]; then # No options - show the pre-menu
		sam_premenu
	else
		# If we're given a core name then we need to set it first
		nextcore=""
		for arg in ${@,,}; do
			case ${arg} in
			arcade | atari2600 | atari5200 | atari7800 | atarilynx | amiga | c64 | fds | gb | gbc | gba | genesis | gg | megacd | neogeo | nes | s32x | sms | snes | tgfx16 | tgfx16cd | psx)
				echo " ${CORE_PRETTY[${arg}]} selected!"
				nextcore="${arg}"
				;;
			esac
		done

		# If the one command was a core then we need to call in again with "start" specified
		if [ ${nextcore} ] && [ ${#} -eq 1 ]; then
			# Move cursor up a line to avoid duplicate message
			echo -n -e "\033[A"
			# Re-enter this function with start added
			parse_cmd ${nextcore} start
			return
		fi

		while [ ${#} -gt 0 ]; do
			case "${1,,}" in
			default) # sam_update relaunches itself
				sam_update autoconfig
				break
				;;
			--sourceonly | --create-gamelists)
				break
				;;
			autoconfig | defaultb)
				tmux kill-session -t MCP &>/dev/null
				there_can_be_only_one
				sam_update
				mcp_start
				sam_enable
				break
				;;
			bootstart) # Start as from init
				env_check ${1}
				# Sleep before startup so clock of Mister can synchronize if connected to the internet.
				# We assume most people don't have RTC add-on so sleep is default.
				# Only start MCP on boot
				sleep ${bootsleep}
				mcp_start
				break
				;;
			start | restart) # Start as a detached tmux session for monitoring
				sam_start
				break
				;;
			start_real) # Start SAM immediately
				env_check ${1}
				tty_init
				bgm_start
				loop_core ${nextcore}
				break
				;;
			skip | next) # Load next game - stops monitor
				echo " Skipping to next game..."
				tmux send-keys -t SAM C-c ENTER
				# break
				;;
			stop) # Stop SAM immediately
				sam_cleanup
				sam_stop
				exit
				break
				;;
			update) # Update SAM
				sam_cleanup
				sam_update
				break
				;;
			enable) # Enable SAM autoplay mode
				env_check ${1}
				sam_enable
				break
				;;
			disable) # Disable SAM autoplay
				sam_cleanup
				sam_disable
				break
				;;
			monitor) # Warn user of changes
				sam_monitor
				break
				;;
			startmonitor)
				sam_start
				sam_monitor
				break
				;;
			amiga | arcade | atari2600 | atari5200 | atari7800 | atarilynx | c64 | fds | gb | gbc | gba | genesis | gg | megacd | neogeo | nes | s32x | sms | snes | tgfx16 | tgfx16cd | psx)
				: # Placeholder since we parsed these above
				;;
			single)
				sam_singlemenu
				break
				;;
			utility)
				sam_utilitymenu
				break
				;;
			autoplay)
				sam_autoplaymenu
				break
				;;
			favorite)
				mglfavorite
				break
				;;
			reset)
				sam_resetmenu
				break
				;;
			config)
				sam_configmenu
				break
				;;
			back)
				sam_menu
				break
				;;
			menu)
				sam_menu
				break
				;;
			cancel) # Exit
				echo " It's pitch dark; You are likely to be eaten by a Grue."
				inmenu=0
				break
				;;
			deleteall)
				deleteall
				break
				;;
			exclude)
				samedit_excltags
				break
				;;
			include)
				samedit_include
				break
				;;
			gamemode)
				sam_gamemodemenu
				break
				;;
			bgm)
				sam_bgmmenu
				break
				;;
			gamelists)
				sam_gamelistmenu
				break
				;;
			creategl)
				creategl
				break
				;;
			deletegl)
				deletegl
				break
				;;
			help)
				sam_help
				break
				;;
			*)
				echo " ERROR! ${1} is unknown."
				echo " Try $(basename -- ${0}) help"
				echo " Or check the Github readme."
				break
				;;
			esac
			shift
		done
	fi
}


# ======== SAM COMMANDS ========
function mcp_start() {

	# If the MCP isn't running we need to start it in monitoring only mode
	if [ -z "$(pidof MiSTer_SAM_MCP)" ]; then
		# ${mrsampath}/MiSTer_SAM_MCP monitoronly &
		tmux new-session -s MCP -d "${mrsampath}/MiSTer_SAM_MCP"
	fi

}

function sam_update() { # sam_update (next command)
	# End script through button push
	echo "Button push." >/tmp/.SAM_Joy_Activity
	# Ensure the MiSTer SAM data directory exists
	mkdir --parents "${mrsampath}" &>/dev/null
	mkdir --parents "${gamelistpath}" &>/dev/null

	if [ ! "$(dirname -- ${0})" == "/tmp" ]; then
		# Warn if using non-default branch for updates
		if [ ! "${branch}" == "main" ]; then
			echo ""
			echo "*******************************"
			echo " Updating from ${branch}"
			echo "*******************************"
			echo ""
		fi

		# Download the newest MiSTer_SAM_on.sh to /tmp
		get_samstuff MiSTer_SAM_on.sh /tmp
		if [ -f /tmp/MiSTer_SAM_on.sh ]; then
			if [ ${1} ]; then
				echo " Continuing setup with latest MiSTer_SAM_on.sh..."
				/tmp/MiSTer_SAM_on.sh ${1}
				exit 0
			else
				echo " Launching latest"
				echo " MiSTer_SAM_on.sh..."
				/tmp/MiSTer_SAM_on.sh update
				exit 0
			fi
		else
			# /tmp/MiSTer_SAM_on.sh isn't there!
			echo " SAM update FAILED"
			echo " No Internet?"
			exit 1
		fi
	else # We're running from /tmp - download dependencies and proceed
		cp --force "/tmp/MiSTer_SAM_on.sh" "/media/fat/Scripts/MiSTer_SAM_on.sh"

		get_partun
		get_samindex
		get_mbc
		get_inputmap
		get_samstuff .MiSTer_SAM/MiSTer_SAM_init
		get_samstuff .MiSTer_SAM/MiSTer_SAM_MCP
		get_samstuff .MiSTer_SAM/MiSTer_SAM_tty2oled
		get_samstuff .MiSTer_SAM/SAM_splash.gsc
		get_samstuff .MiSTer_SAM/MiSTer_SAM_joy.py
		get_samstuff .MiSTer_SAM/MiSTer_SAM_keyboard.py
		get_samstuff .MiSTer_SAM/MiSTer_SAM_mouse.py
		#blacklist files
		get_samstuff .MiSTer_SAM/SAM_Gamelists/arcade_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists
		get_samstuff .MiSTer_SAM/SAM_Gamelists/tgfx16cd_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists
		get_samstuff .MiSTer_SAM/SAM_Gamelists/megacd_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists
		get_samstuff .MiSTer_SAM/SAM_Gamelists/fds_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists

		get_samstuff MiSTer_SAM_off.sh /media/fat/Scripts

		if [ -f /media/fat/Scripts/MiSTer_SAM.ini ]; then
			echo " MiSTer SAM INI already exists... Merging with new ini."
			get_samstuff MiSTer_SAM.ini /tmp
			echo " Backing up MiSTer_SAM.ini to MiSTer_SAM.ini.bak"
			cp /media/fat/Scripts/MiSTer_SAM.ini /media/fat/Scripts/MiSTer_SAM.ini.bak
			echo -n " Merging ini values.."
			# In order for the following awk script to replace variable values, we need to change our ASCII art from "=" to "-"
			sed -i 's/==/--/g' /media/fat/Scripts/MiSTer_SAM.ini
			sed -i 's/-=/--/g' /media/fat/Scripts/MiSTer_SAM.ini
			awk -F= 'NR==FNR{a[$1]=$0;next}($1 in a){$0=a[$1]}1' /media/fat/Scripts/MiSTer_SAM.ini /tmp/MiSTer_SAM.ini >/tmp/MiSTer_SAM.tmp && mv --force /tmp/MiSTer_SAM.tmp /media/fat/Scripts/MiSTer_SAM.ini
			echo "Done."

		else
			get_samstuff MiSTer_SAM.ini /media/fat/Scripts
		fi
		



	fi

	echo " Update complete!"
	return

	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_menu
	fi

}

function sam_enable() { # Enable autoplay
	echo -n " Enabling MiSTer SAM Autoplay..."

	# Awaken daemon
	# Check for and delete old fashioned scripts to prefer /media/fat/linux/user-startup.sh
	# (https://misterfpga.org/viewtopic.php?p=32159#p32159)

	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	# Add new startup way
	if [ ! -e "${userstartup}" ] && [ -e /etc/init.d/S99user ]; then
		if [ -e "${userstartuptpl}" ]; then
			echo "Copying ${userstartuptpl} to ${userstartup}"
			cp "${userstartuptpl}" "${userstartup}"
		else
			echo "Building ${userstartup}"
		fi
	fi
	if [ $(grep -ic "mister_sam" ${userstartup}) = "0" ]; then
		echo -e "Add MiSTer SAM to ${userstartup}\n"
		echo -e "\n# Startup MiSTer_SAM - Super Attract Mode" >>${userstartup}
		echo -e "[[ -e ${mrsampath}/MiSTer_SAM_init ]] && ${mrsampath}/MiSTer_SAM_init \$1 &" >>"${userstartup}"
	fi
	echo " SAM install complete."
	echo -e "\n\n\n"
	source "${misterpath}/Scripts/MiSTer_SAM.ini"
	boot_samtimeout=$((${samtimeout} + ${bootsleep}))
	echo -ne "\e[1m" SAM will start ${boot_samtimeout} sec. after boot"\e[0m"
	if [ "${menuonly,,}" == "yes" ]; then
		echo -ne "\e[1m" in the main menu"\e[0m"
	else
		echo -ne "\e[1m" whenever controller is not in use"\e[0m"
	fi
	echo -e "\e[1m" and show each game for ${gametimer} sec."\e[0m"
	echo -ne "\e[1m" First run will take some time to compile game list... please wait."\e[0m"
	echo -e "\n\n\n"
	sleep 5

	"${misterpath}/Scripts/MiSTer_SAM_on.sh" start

	exit
}

function sam_disable() { # Disable autoplay

	echo -n " Disabling SAM autoplay..."
	# Clean out existing processes to ensure we can update

	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	there_can_be_only_one
	sed -i '/MiSTer_SAM/d' ${userstartup}
	sync
	echo " Done!"
}

function sam_help() { # sam_help
	echo " start - start immediately"
	echo " skip - skip to the next game"
	echo " stop - stop immediately"
	echo ""
	echo " update - self-update"
	echo " monitor - monitor SAM output"
	echo ""
	echo " enable - enable autoplay"
	echo " disable - disable autoplay"
	echo ""
	echo " menu - load to menu"
	echo ""
	echo " arcade, genesis, gba..."
	echo " games from one system only"
	exit 2
}

# ======== UTILITY FUNCTIONS ========
function there_can_be_only_one() { # there_can_be_only_one
	# If another attract process is running kill it
	# This can happen if the script is started multiple times
	echo -n " Stopping other running instances of ${samprocess}..."

	kill_1=$(ps -o pid,args | grep '[M]iSTer_SAM_init start' | awk '{print $1}' | head -1)
	kill_2=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh start_real' | awk '{print $1}')
	kill_3=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh bootstart_real' | awk '{print $1}' | head -1)

	[[ ! -z ${kill_1} ]] && kill -9 ${kill_1} >/dev/null
	for kill in ${kill_2}; do
		[[ ! -z ${kill_2} ]] && kill -9 ${kill} >/dev/null
	done
	[[ ! -z ${kill_3} ]] && kill -9 ${kill_3} >/dev/null

	sleep 1

	echo " Done!"
}

function kill_all_sams() {
	# Kill all SAM processes except for currently running
	ps -ef | grep -i '[M]iSTer_SAM' | awk -v me=${sampid} '$1 != me {print $1}' | xargs kill &>/dev/null
}


function sam_exit() { # args = ${1}(exit_code required) ${2} optional error message
	sam_cleanup
	if [ ${1} -eq 0 ]; then # just exit
		echo "load_core /media/fat/menu.rbf" >/dev/MiSTer_cmd
		sleep 1
		echo " Done!"
		echo " Thanks for playing!"
	elif [ ${1} -eq 1 ]; then # Error
		echo "load_core /media/fat/menu.rbf" >/dev/MiSTer_cmd
		sleep 1
		echo " Done!"
		echo " There was an error ${2}" # Pass error messages in ${2}
	elif [ ${1} -eq 2 ]; then        # Play Current Game
		sleep 1
	elif [ ${1} -eq 3 ]; then # Play Current Game, relaunch because of mute
		sleep 1
		if [ "${nextcore}" == "arcade" ]; then
			mute=no
			mute "${mrasetname}"
			echo "load_core ${MRAPATH}" >/dev/MiSTer_cmd
		else
			mute=no
			mute "${CORE_LAUNCH[${nextcore}]}"
			echo "load_core /tmp/SAM_game.mgl" >/dev/MiSTer_cmd
		fi
	fi
}

function play_or_exit() {
	if [ "${playcurrentgame}" == "yes" ] && ([ ${mute} == "yes" ] || [ ${mute} == "core" ]); then
		sam_exit 3
	elif [ "${playcurrentgame}" == "yes" ] && [ ${mute} == "no" ]; then
		sam_exit 2
	else
		sam_exit 0
	fi
}




function env_check() {
	# Check if we've been installed
	if [ ! -f "${mrsampath}/partun" ] || [ ! -f "${mrsampath}/MiSTer_SAM_MCP" ]; then
		echo " SAM required files not found."
		echo " Surprised? Check your INI."
		sam_update ${1}
		echo " Setup complete."
	fi
}

function deleteall() {
	# In case of issues, reset SAM

	there_can_be_only_one
	if [ -d "${mrsampath}" ]; then
		echo "Deleting MiSTer_SAM folder"
		rm -rf "${mrsampath}"
	fi
	if [ -f "/media/fat/Scripts/MiSTer_SAM.ini" ]; then
		echo "Deleting MiSTer_SAM.ini"
		cp /media/fat/Scripts/MiSTer_SAM.ini /media/fat/Scripts/MiSTer_SAM.ini.bak
		rm /media/fat/Scripts/MiSTer_SAM.ini
	fi
	if [ -f "/media/fat/Scripts/MiSTer_SAM_off.sh" ]; then
		echo "Deleting MiSTer_SAM_off.sh"
		rm /media/fat/Scripts/MiSTer_SAM_off.sh
	fi

	if [ -d "/media/fat/Scripts/SAM_Gamelists" ]; then
		echo "Deleting Gamelist folder"
		rm -rf "/media/fat/Scripts/SAM_Gamelists"
	fi

	if ls /media/fat/Config/inputs/*_input_1234_5678_v3.map 1>/dev/null 2>&1; then
		echo "Deleting Keyboard mapping files"
		rm /media/fat/Config/inputs/*_input_1234_5678_v3.map
	fi
	# Remount root as read-write if read-only so we can remove daemon
	mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
	[ "$RO_ROOT" == "true" ] && mount / -o remount,rw

	# Delete daemon
	echo "Deleting Auto boot Daemon..."
	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi
	echo "Done."

	sed -i '/MiSTer_SAM/d' ${userstartup}
	sed -i '/Super Attract/d' ${userstartup}

	printf "\nAll files deleted except for MiSTer_SAM_on.sh\n"
	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_resetmenu
	else
		printf "\nGamelist reset successful. Please start SAM now.\n"
		sleep 1
		parse_cmd stop
	fi
}


function deletegl() {
	# In case of issues, reset game lists

	there_can_be_only_one
	if [ -d "${mrsampath}/SAM_Gamelists" ]; then
		echo "Deleting MiSTer_SAM Gamelist folder"
		rm -rf "${mrsampath}/SAM_Gamelists"
	fi

	if [ -d "${mrsampath}/SAM_Count" ]; then
		rm -rf "${mrsampath}/SAM_Count"
	fi
	if [ -d /tmp/.SAM_List ]; then
		rm -rf /tmp/.SAM_List
	fi

	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_menu
	else
		echo -e "\nGamelist reset successful. Please start SAM now.\n"
		sleep 1
		parse_cmd stop
	fi
}

# Check if gamelists exist
function checkgl() {
	if ! compgen -G "${gamelistpath}/*_gamelist.txt" >/dev/null; then
		echo " Creating Game Lists"
		read_samini
		creategl
	fi
}

function creategl() {
	init_vars 
	read_samini 
	init_paths 
	init_data
	create_all_gamelists_old="${create_all_gamelists}"
	rebuild_freq_arcade_old="${rebuild_freq_arcade}"
	rebuild_freq_old="${rebuild_freq}"
	create_all_gamelists="Yes"
	rebuild_freq_arcade="Always"
	rebuild_freq="Always"
	create_game_lists
	create_all_gamelists="${create_all_gamelists_old}"
	rebuild_freq_arcade="${rebuild_freq_arcade_old}"
	rebuild_freq="${rebuild_freq_old}"
	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_menu
	else
		echo -e "\nGamelist creation successful. Please start SAM now.\n"
		sleep 1
		parse_cmd stop
	fi
}

function skipmessage() {
	if [ "${skipmessage}" == "yes" ] && [ "${CORE_SKIP[${nextcore}]}" == "yes" ]; then
		# Skip past bios/safety warnings
		sleep 10
		"${mrsampath}/mbc" raw_seq :31
	fi
}

function mglfavorite() {
	# Add current game to _Favorites folder

	if [ ! -d "${misterpath}/_Favorites" ]; then
		mkdir -p "${misterpath}/_Favorites"
	fi
	cp /tmp/SAM_game.mgl "${misterpath}/_Favorites/$(cat /tmp/SAM_Game.txt).mgl"

}

function bgm_start() {

	if [ "${bgm}" == "yes" ] && [ "${mute}" == "core" ]; then
		echo -n "set playincore yes" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
		echo -n "play" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
	fi

}

function bgm_stop() {

	if [ "${bgm}" == "yes" ]; then
		echo -n "set playincore no" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
		echo -n "stop" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
	fi

}


function samdebug() {
	if [ "${samdebug}" == "yes" ]; then
		if [ "${1}" == "-n" ]; then
			echo -en "\e[1m\e[31m${2-}\e[0m"
		else
			echo -e "\e[1m\e[31m${1-}\e[0m"
		fi
	fi
}

function samquiet() {
	if [ "${samquiet}" == "no" ]; then
		if [ "${1}" == "-n" ]; then
			echo -en "\e[1m\e[32m${2-}\e[0m"
		else
			echo -e "\e[1m\e[32m${1-}\e[0m"
		fi
	fi
}



# ======== DOWNLOAD FUNCTIONS ========
function curl_download() { # curl_download ${filepath} ${URL}

	curl \
		--connect-timeout 15 --max-time 600 --retry 3 --retry-delay 5 --silent --show-error \
		--insecure \
		--fail \
		--location \
		-o "${1}" \
		"${2}"
}

# ======== UPDATER FUNCTIONS ========
function get_samstuff() { #get_samstuff file (path)
	if [ -z "${1}" ]; then
		return 1
	fi

	filepath="${2}"
	if [ -z "${filepath}" ]; then
		filepath="${mrsampath}"
	fi

	echo -n " Downloading from ${repository_url}/blob/${branch}/${1} to ${filepath}/..."
	curl_download "/tmp/${1##*/}" "${repository_url}/blob/${branch}/${1}?raw=true"

	if [ ! "${filepath}" == "/tmp" ]; then
		mv --force "/tmp/${1##*/}" "${filepath}/${1##*/}"
	fi

	if [ "${1##*.}" == "sh" ]; then
		chmod +x "${filepath}/${1##*/}"
	fi

	echo " Done!"
}

function get_partun() {
	REPOSITORY_URL="https://github.com/woelper/partun"
	echo " Downloading partun - needed for unzipping roms from big archives..."
	echo " Created for MiSTer by woelper - Talk to him at this year's PartunCon"
	echo " ${REPOSITORY_URL}"
	latest=$(curl -s -L --insecure https://api.github.com/repos/woelper/partun/releases/latest | jq -r ".assets[] | select(.name | contains(\"armv7\")) | .browser_download_url")
	curl_download "/tmp/partun" "${latest}"
	mv --force "/tmp/partun" "${mrsampath}/partun"
	echo " Done!"
}

function get_samindex() {
	echo " Downloading samindex - needed for creating gamelists..."
	echo " Created for MiSTer by wizzo"
	echo " https://github.com/wizzomafizzo/mrext"
	latest="${repository_url}/blob/${branch}/.MiSTer_SAM/samindex.zip?raw=true"
	curl_download "/tmp/samindex.zip" "${latest}"
	unzip -ojq /tmp/samindex.zip -d "${mrsampath}" # &>/dev/null
	echo " Done!"
}

function get_mbc() {
	echo " Downloading mbc - Control MiSTer from cmd..."
	echo " Created for MiSTer by pocomane"
	get_samstuff .MiSTer_SAM/mbc
}

function get_inputmap() {
	echo -n " Downloading input maps - needed to skip past BIOS for some systems..."
	get_samstuff .MiSTer_SAM/inputs/GBA_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	get_samstuff .MiSTer_SAM/inputs/MegaCD_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	get_samstuff .MiSTer_SAM/inputs/NES_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	get_samstuff .MiSTer_SAM/inputs/TGFX16_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	echo " Done!"
}

# ========= SAM START AND STOP =========
function sam_start() {
	env_check
	# Terminate any other running SAM processes
	there_can_be_only_one
	mcp_start
	if [ "${ttyenable}" == "yes" ]; then echo " Starting tty2oled... "; fi
	echo " Starting SAM in the background."
	tmux new-session -x 180 -y 40 -n "-= SAM Monitor -- Detach with ctrl-b, then push d  =-" -s SAM -d "${misterpath}/Scripts/MiSTer_SAM_on.sh" start_real ${nextcore}
}

function sam_stop() {
	# Stop all SAM processes and reboot to menu

	[ ! -z ${samprocess} ] && echo -n " Stopping other running instances of ${samprocess}..."

	echo "load_core /media/fat/menu.rbf" >/dev/MiSTer_cmd

	sleep 1

	echo " Done!"
	echo " Thanks for playing!"

	kill_1=$(ps -o pid,args | grep '[M]CP' | awk '{print $1}' | head -1)
	kill_2=$(ps -o pid,args | grep '[S]AM' | awk '{print $1}' | head -1)
	kill_3=$(ps -o pid,args | grep '[i]notifywait.*SAM' | awk '{print $1}' | head -1)
	kill_4=$(ps -o pid,args | grep -i '[M]iSTer_SAM' | awk '{print $1}')

	[[ ! -z ${kill_1} ]] && tmux kill-session -t MCP &>/dev/null
	[[ ! -z ${kill_2} ]] && tmux kill-session -t SAM &>/dev/null
	[[ ! -z ${kill_3} ]] && kill -9 ${kill_4} &>/dev/null
	for kill in ${kill_4}; do
		[[ ! -z ${kill_4} ]] && kill -9 ${kill} &>/dev/null
	done
						
}

# ========= SAM MONITOR =========
function sam_monitor() {

	tmux attach-session -t SAM
}

# ======== SAM OPERATIONAL FUNCTIONS ========
function loop_core() { # loop_core (core)
	echo -e " Starting Super Attract Mode...\n Let Mortal Kombat begin!\n"
	# Reset game log for this session
	echo "" | >/tmp/SAM_Games.log

	while :; do

		while [ ${counter} -gt 0 ]; do
			trap 'counter=0' INT #Break out of loop for skip & next command
			echo -ne " Next game in ${counter}...\033[0K\r"
			sleep 1
			((counter--))
			
			#tty2oled counter
			if [ "${ttyenable}" == "yes" ]; then
			((tty_counter++))
				if [ "${tty_counter}" -gt 11 ]; then
					tty_currentinfo[counter]=$(printf "%03d" ${counter})
					update_counter ${tty_currentinfo[counter]} &
				fi
			fi

			if [ -s /tmp/.SAM_Mouse_Activity ]; then
				if [ "${listenmouse}" == "yes" ]; then
					echo " Mouse activity detected!"
					play_or_exit
				else
					echo " Mouse activity ignored!"
					echo "" | >/tmp/.SAM_Mouse_Activity
				fi
			fi

			if [ -s /tmp/.SAM_Keyboard_Activity ]; then
				if [ "${listenkeyboard}" == "yes" ]; then
					echo " Keyboard activity detected!"
					play_or_exit

				else
					echo " Keyboard activity ignored!"
					echo "" | >/tmp/.SAM_Keyboard_Activity
				fi
			fi

			if [ -s /tmp/.SAM_Joy_Activity ]; then
				if [ "${listenjoy}" == "yes" ]; then
					echo " Controller activity detected!"
					play_or_exit
				else
					echo " Controller activity ignored!"
					echo "" | >/tmp/.SAM_Joy_Activity
				fi
			fi

		done

		counter=${gametimer}
		next_core ${1}
		tty_counter=0

	done
	trap - INT
	sleep 1
}

# ======== tty2oled FUNCTIONS ========

function tty_init() { # tty_init
	if [ "${ttyenable}" == "yes" ]; then

		# tty2oled initialization
		declare -gi START=$(date +%s)
		samquiet " Init tty2oled, loading variables... "
		source ${ttysystemini}
		source ${ttyuserini}
		ttydevice=${TTYDEV}
		ttypicture=${picturefolder}
		ttypicture_pri=${picturefolder_pri}
		set_scroll_speed
		

		# Clear Serial input buffer first
		samquiet "-n" " Clear tty2oled Serial Input Buffer..."
		while read -t 0 sdummy <${ttydevice}; do continue; done
		samquiet " Done!"

		# Stopping ScreenSaver
		samquiet "-n" " Stopping tty2oled ScreenSaver..."
		echo "CMDSAVER,0,0,0" >${ttydevice}
		sleep 2
		samquiet " Done!"
		
		#Show Splash
		echo "CMDAPD,SAM_splash" >${ttydevice}
		tail -n +4 "/media/fat/Scripts/.MiSTer_SAM/SAM_splash.gsc" | xxd -r -p >${ttydevice}
		echo "CMDSPIC,-1" >${ttydevice}
		sleep 5
	fi
}

function tty_display() { # tty_update core game
	args=$(echo "${@}" | sed "s/ -A / -gA /")
	eval "${args}"
	# Wait for tty2oled daemon to show the core logo
	tty_senddata "${tty_currentinfo[core]}"
	sleep 10
	# Clear Display	with Random effect
	echo "CMDCLST,-1,0" >"${ttydevice}"
	sleep 1
	#tty_counter=1
	echo "CMDTXT,103,15,0,0,20,${tty_currentinfo[name_scroll]}" >${ttydevice}
	echo "CMDTXT,102,5,0,0,40,${tty_currentinfo[core_pretty]}" >${ttydevice}
	#echo "CMDTXT,102,15,0,0,60,Next game in ${tty_currentinfo[counter]}" >${ttydevice}
	prev_name_scroll="${tty_currentinfo[name_scroll]}"
	prev_counter="${tty_currentinfo[counter]}"
}


function update_counter() {
	tty_currentinfo[counter]="$1"
	if [ ${tty_currentinfo[update_pause]} -gt 0 ]; then
		((tty_currentinfo[update_pause]--))
	else
		update_name_scroll
	fi
	echo "CMDTXT,102,0,0,0,60,Next game in ${prev_counter}" >${ttydevice}
	echo "CMDTXT,102,15,0,0,60,Next game in ${tty_currentinfo[counter]}" >${ttydevice}
	prev_counter="${tty_currentinfo[counter]}"
	echo "CMDDUPD" >"${ttydevice}"
}

function set_scroll_speed() {
	ttyscroll_speed_int=$((${ttyscroll_speed} - 1))
}

function update_name_scroll() {
	if [ ${ttyscroll_speed} -gt 0 ]; then
		if [ ${#tty_currentinfo[name]} -gt 21 ]; then
			if [ ${ttyscroll_speed_int} -gt 0 ]; then
				((ttyscroll_speed_int--))
			else
				set_scroll_speed
				if [ ${tty_currentinfo[name_scroll_direction]} -eq 1 ]; then
					if [ ${tty_currentinfo[name_scroll_position]} -lt $((${#tty_currentinfo[name]} - 21)) ]; then
						((tty_currentinfo[name_scroll_position]++))
					else
						tty_currentinfo[name_scroll_direction]=0
					fi
				elif [ ${tty_currentinfo[name_scroll_direction]} -eq 0 ]; then
					if [ ${tty_currentinfo[name_scroll_position]} -gt 0 ]; then
						((tty_currentinfo[name_scroll_position]--))
					else
						tty_currentinfo[name_scroll_direction]=1
					fi
				fi
				tty_currentinfo[name_scroll]="${tty_currentinfo[name]:${tty_currentinfo[name_scroll_position]}:21}"
				echo "CMDTXT,103,0,0,0,20,${prev_name_scroll}" >${ttydevice}
				echo "CMDTXT,103,15,0,0,20,${tty_currentinfo[name_scroll]}" >${ttydevice}
				prev_name_scroll="${tty_currentinfo[name_scroll]}"
			fi
		fi
	fi
}



# USB Send-Picture-Data function
function tty_senddata() {
	newcore="${1}"
	unset picfnam
	if [ -e "${ttypicture_pri}/${newcore}.gsc" ]; then # Check for _pri pictures
		picfnam="${ttypicture_pri}/${newcore}.gsc"
	elif [ -e "${ttypicture_pri}/${newcore}.xbm" ]; then
		picfnam="${ttypicture_pri}/${newcore}.xbm"
	else
		picfolders="gsc_us xbm_us gsc xbm xbm_text" # If no _pri picture found, try all the others
		[ "${USE_US_PICTURE}" = "no" ] && picfolders="${picfolders//gsc_us xbm_us/}"
		[ "${USE_GSC_PICTURE}" = "no" ] && picfolders="${picfolders//gsc_us/}" && picfolders="${picfolders//gsc/}"
		[ "${USE_TEXT_PICTURE}" = "no" ] && picfolders="${picfolders//xbm_text/}"
		for picfolder in ${picfolders}; do
			for ((c = "${#newcore}"; c >= 1; c--)); do                               # Manipulate string...
				picfnam="${ttypicture}/${picfolder^^}/${newcore:0:${c}}.${picfolder:0:3}" # ...until it matches something
				[ -e "${picfnam}" ] && break
			done
			[ -e "${picfnam}" ] && break
		done
	fi
	if [ -e "${picfnam}" ]; then # Exist?
		# For testing...
		samdebug "-------------------------------------------"
		samdebug " tty2oled sending Corename: ${1} "
		samdebug " tty2oled found/send Picture : ${picfnam} "
		samdebug "-------------------------------------------"

		echo "CMDCOR,${1}" >"${ttydevice}"                # Send CORECHANGE" Command and Corename
		tail -n +4 "${picfnam}" | xxd -r -p >${ttydevice} # The Magic, send the Picture-Data up from Line 4 and proces
		sleep 1                                    # sleep needed here ?!
	else         
		sleep 0.25                                      # No Picture available!
		echo "${1}" >"${ttydevice}"                       # Send just the CORENAME
		sleep 1                                         # sleep needed here ?!
	fi                                                 # End if Picture check
}

function tty_exit() {
	if [ "${ttyenable}" == "yes" ]; then
		# Clear Display	with Random effect
		echo "CMDCLST,-1,0" >${ttydevice}
		sleep 2

		# Starting tty2oled daemon only if needed
		if [[ ! $(ps -o pid,args | grep '[t]ty2oled.sh' | awk '{print $1}') ]]; then
			sleep 1
			tmux new -s TTY -d "/media/fat/tty2oled/tty2oled.sh"
		fi
	fi
}


function reset_core_gl() { # args ${nextcore}
	echo " Deleting old game lists for ${1^^}..."
	rm "${gamelistpath}/${1}_gamelist.txt" &>/dev/null
	sync
}


function core_error() { # core_error core /path/to/ROM
	if [ ${romloadfails} -lt ${coreretries} ]; then
		declare -g romloadfails=$((romloadfails + 1))
		echo " ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
		echo " Trying to find another rom..."
		next_core ${1}
	else
		echo " ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
		echo " ERROR: Core ${1} is blacklisted!"
		declare -g corelist=("${corelist[@]/${1}/}")
		echo " List of cores is now: ${corelist[@]}"
		declare -g romloadfails=0
		# Load a different core
		next_core
	fi
}


function disable_bootrom() {
	if [ "${disablebootrom}" == "Yes" ]; then
		# Make Bootrom folder inaccessible until restart
		[ -d "${misterpath}/Bootrom" ] && [ "$(mount | grep -ic 'bootrom')" == "0" ] && mount --bind /mnt "${misterpath}/Bootrom"
		# Disable Nes bootroms except for FDS Bios (boot0.rom)
		[ -f "${misterpath}/Games/NES/boot1.rom" ] && [ "$(mount | grep -ic 'nes/boot1.rom')" == "0" ] && touch /tmp/brfake && mount --bind /tmp/brfake "${misterpath}/Games/NES/boot1.rom"
		[ -f "${misterpath}/Games/NES/boot2.rom" ] && [ "$(mount | grep -ic 'nes/boot2.rom')" == "0" ] && touch /tmp/brfake && mount --bind /tmp/brfake "${misterpath}/Games/NES/boot2.rom"
		[ -f "${misterpath}/Games/NES/boot3.rom" ] && [ "$(mount | grep -ic 'nes/boot3.rom')" == "0" ] && touch /tmp/brfake && mount --bind /tmp/brfake "${misterpath}/Games/NES/boot3.rom"
	fi
}

function mute() {
	if [ "${mute}" == "yes" ]; then
		# Mute Global Volume
		echo -e "\0020\c" >/media/fat/config/Volume.dat
	elif [ "${mute}" == "core" ]; then
		#  Global Volume
		echo -e "\0000\c" >/media/fat/config/Volume.dat
		# Mute Core Volumes
		echo -e "\0006\c" >"/media/fat/config/${1}_volume.cfg"
	elif [ "${mute}" == "no" ]; then
		#  Global Volume
		echo -e "\0000\c" >/media/fat/config/Volume.dat
		#  Core Volumes
		echo -e "\0000\c" >"/media/fat/config/${1}_volume.cfg"
	fi
}



# ======== ROMFINDER ========
function create_romlist() { # args ${nextcore} "${DIR}"

	${mrsampath}/samindex -s ${nextcore} -o "${gamelistpath}"
}

function check_list() { # args ${nextcore} 
	# If gamelist is not in /tmp dir, let's put it there
	if [ ! -f "${gamelistpath}/${1}_gamelist.txt" ]; then
		echo " Creating game list at ${gamelistpath}/${1}_gamelist.txt"
		create_romlist
	fi


	# Check if zip still exists
	if [ "$(grep -c ".zip" ${gamelistpath}/${1}_gamelist.txt)" != "0" ]; then
		mapfile -t zipsinfile < <(grep ".zip" "${gamelistpath}/${1}_gamelist.txt" | awk -F".zip" '!seen[$1]++' | awk -F".zip" '{print $1}' | sed -e 's/$/.zip/')
		for zips in "${zipsinfile[@]}"; do
			if [ ! -f "${zips}" ]; then
				echo " Creating new game list because zip file[s] seems to have changed."
				create_romlist
			fi
		done
	fi

	# If gamelist is not in /tmp dir, let's put it there
	if [ -s "${gamelistpathtmp}/${1}_gamelist.txt" ]; then

		# Pick the actual game
		rompath="$(cat ${gamelistpathtmp}/${1}_gamelist.txt | shuf --head-count=1)"
	else

		# Repopulate list
		if [ -f "${gamelistpath}/${1}_gamelist_exclude.txt" ]; then
			if [ "${samquiet}" == "no" ]; then echo -n " Exclusion list found. Excluding games now..."; fi
			comm -13 <(sort <"${gamelistpath}/${1}_gamelist_exclude.txt") <(sort <"${gamelistpath}/${1}_gamelist.txt") >${tmpfile}
			awk -F'/' '!seen[$NF]++' ${tmpfile} >"${gamelistpathtmp}/${1}_gamelist.txt"
			if [ "${samquiet}" == "no" ]; then echo "Done."; fi
			rompath="$(cat ${gamelistpathtmp}/${1}_gamelist.txt | shuf --head-count=1)"
		else
			awk -F'/' '!seen[$NF]++' "${gamelistpath}/${1}_gamelist.txt" >"${gamelistpathtmp}/${1}_gamelist.txt"
			# cp "${gamelistpath}/${1}_gamelist.txt" "${gamelistpathtmp}/${1}_gamelist.txt" &>/dev/null
			rompath="$(cat ${gamelistpathtmp}/${1}_gamelist.txt | shuf --head-count=1)"
		fi
	fi

	# Make sure file exists since we're reading from a static list
	if [[ ! "${rompath,,}" == *.zip* ]]; then
		if [ ! -f "${rompath}" ]; then
			if [ "${samquiet}" == "no" ]; then echo " Creating new game list because file not found."; fi
			create_romlist 
		fi
	fi

	# Delete played game from list
	if [ "${samquiet}" == "no" ]; then echo " Selected file: ${rompath}"; fi
	if [ "${norepeat}" == "yes" ]; then
		awk -vLine="$rompath" '!index($0,Line)' "${gamelistpathtmp}/${1}_gamelist.txt" >${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${1}_gamelist.txt"
	fi
}

# This function will pick a random rom from the game list.
function next_core() { # next_core (core)
	
	if [ -z "${corelist[@]//[[:blank:]]/}" ]; then
		echo " ERROR: FATAL - List of cores is empty. Nothing to do!"
		exit 1
	fi

	# Set $nextcore from $corelist
	if [ -z "${1}" ]; then
		# Don't repeat same core twice

		if [ ! -z ${nextcore} ]; then

			corelisttmp=$(echo "$corelist" | awk '{print $0" "}' | sed "s/${nextcore} //" | tr -s ' ')

			# Choose the actual core
			nextcore="$(echo ${corelisttmp} | xargs shuf --head-count=1 --echo)"
			
			# If core is single core make sure we don't run out of cores
			if [ -z ${nextcore} ]; then
				nextcore="$(echo ${corelist} | xargs shuf --head-count=1 --echo)"
			fi

		else
			nextcore="$(echo ${corelist} | xargs shuf --head-count=1 --echo)"
		fi
		
		#Special case for first run
		if [ "$(find "${gamelistpath}" -name "*_gamelist.txt" | wc -l)" == "0" ]; then
			"${mrsampath}"/samindex -q -s arcade -o "${gamelistpath}"
		fi
		
		if [ "$(find "${gamelistpath}" -name "*_gamelist.txt" | wc -l)" == "0" ]; then
			echo " Couldn't find Arcade games. Please run update_all.sh first"
			exit
		fi

		if [ "$(find "${gamelistpath}" -name "*_gamelist.txt" | wc -l)" == "1" ]; then
			nextcore="$(find "${gamelistpath}" -name "*_gamelist.txt" | shuf | awk -F'/' '{ print $NF }' | awk -F'_' '{print$1}' | head -1)"
			for core in `echo $corelist`; do
				"${mrsampath}"/samindex -q -s "${core}" -o "${gamelistpath}" &
			done
		fi

		if [ "${samquiet}" == "no" ]; then echo -e " Selected core: \e[1m${nextcore^^}\e[0m"; fi

	elif [ "${1,,}" == "countdown" ] && [ "$2" ]; then
		countdown="countdown"
		nextcore="${2}"
	elif [ "${2,,}" == "countdown" ]; then
		nextcore="${1}"
		countdown="countdown"
	fi

	if [ "${nextcore}" == "arcade" ]; then
		# If this is an arcade core we go to special code
		load_core_arcade
		return
	fi
	if [ "${nextcore}" == "amiga" ]; then
		# If this is Amiga core we go to special code
		if [ -f "${amigapath}/MegaAGS.hdf" ]; then
			load_core_amiga
		else
			echo " ERROR - MegaAGS Pack not found in Amiga folder. Skipping to next core..."
			declare -g corelist=("${corelist[@]/${1}/}")
			next_core
		fi
		return
	fi
	
	check_list ${nextcore} 

	romname=$(basename "${rompath}")

	# Sanity check that we have a valid rom in var
	extension="${rompath##*.}"
	extlist=$(echo "${CORE_EXT[${nextcore}]}" | sed -e "s/,/ /g")
				
	if [[ ! "$(echo "${extlist}" | grep -i "${extension}")" ]]; then
		if [ "${samquiet}" == "no" ]; then echo -e " Wrong extension found: \e[1m${extension^^}\e[0m"; fi
		if [ "${samquiet}" == "no" ]; then echo -e " Picking new rom.."; fi

		#create_romlist
		next_core ${nextcore}
		return
	fi

	# If there is an exclude list check it
	declare -n excludelist="${nextcore}exclude"
	if [ ${#excludelist[@]} -gt 0 ]; then
		for excluded in "${excludelist[@]}"; do
			if [ "${romname}" == "${excluded}" ]; then
				echo " ${romname} is excluded - SKIPPED"
				awk -vLine="${romname}" '!index($0,Line)' "${gamelistpathtmp}/${nextcore}_gamelist.txt" >${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt" 2>/dev/null
				next_core
				return
			fi
		done
	fi
	if [ "${FIRSTRUN[${nextcore}]}" == "0" ]; then
		#Check exclusion
		if [ -f "${excludepath}/${nextcore}_excludelist.txt" ]; then
			if [ "${samquiet}" == "no" ]; then echo " Found excludelist for core ${nextcore}". Stripping out unwanted games now.; fi
			grep -vf "${gamelistpath}/${nextcore}_excludelist.txt" "${gamelistpathtmp}/${nextcore}_gamelist.txt" > ${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"
		fi
	
		#Check blacklist	
		if [ -f "${gamelistpath}/${nextcore}_blacklist.txt" ]; then
			if [ "${samquiet}" == "no" ]; then echo " Found blacklist for core ${nextcore}". Stripping out unwanted games now.; fi
			grep -vf "${gamelistpath}/${nextcore}_blacklist.txt" "${gamelistpathtmp}/${nextcore}_gamelist.txt" > ${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"
		fi
		FIRSTRUN[${nextcore}]=1
	fi

	if [ -z "${rompath}" ]; then
		core_error "${nextcore}" "${rompath}"
	else
		if [ -f "${rompath}.sam" ]; then
			source "${rompath}.sam"
		fi

		declare -g romloadfails=0
		load_core "${nextcore}" "${rompath}" "${romname%.*}" "${countdown}"
	fi
}

function load_core() { # load_core core /path/to/rom name_of_rom (countdown)

	gamename=""
	if [ ${1} == "neogeo" ] && [ ${useneogeotitles} == "yes" ]; then
		if [ ${neogeoregion} == "english" ]; then
			gamename="${NEOGEO_PRETTY_ENGLISH[${3}]}"
		elif [ ${neogeoregion} == "japanese" ]; then
			gamename="${NEOGEO_PRETTY_JAPANESE[${3}]}"
			[[ ! "${gamename}" ]] && gamename="${NEOGEO_PRETTY_ENGLISH[${3}]}"
		fi
	fi
	if [ ! "${gamename}" ]; then
		gamename="${3}"
	fi

	echo -n " Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${1}]}\e[0m: "
	echo -e "\e[1m${gamename}\e[0m"
	echo "$(date +%H:%M:%S) - ${1} - ${3}" $(if [ ${1} == "neogeo" ] && [ ${useneogeotitles} == "yes" ]; then echo "(${gamename})"; fi) >>/tmp/SAM_Games.log
	echo "${3} (${1}) "$(if [ ${1} == "neogeo" ] && [ ${useneogeotitles} == "yes" ]; then echo "(${gamename})"; fi) >/tmp/SAM_Game.txt
	tty_corename="${TTY2OLED_PIC_NAME[${1}]}"

	if [ "${4}" == "countdown" ]; then
		for i in {5..1}; do
			echo -ne " Loading game in ${i}...\033[0K\r"
			sleep 1
		done
	fi

	if [ "${ttyenable}" == "yes" ]; then
		tty_currentinfo=(
			[core_pretty]="${CORE_PRETTY[${nextcore}]}"
			[name]="${gamename}"
			[core]=${tty_corename}
			[counter]=${gametimer}
			[name_scroll]="${gamename:0:21}"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
		)
		tty_display "${tty_currentinfo}" &
	fi
	

	# Create mgl file and launch game
	if [ -s /tmp/SAM_game.mgl ]; then
		mv /tmp/SAM_game.mgl /tmp/SAM_game.previous.mgl
	fi

	mute "${CORE_LAUNCH[${nextcore}]}"

	echo "<mistergamedescription>" >/tmp/SAM_game.mgl
	echo "<rbf>${CORE_PATH_RBF[${nextcore}]}/${MGL_CORE[${nextcore}]}</rbf>" >>/tmp/SAM_game.mgl
	echo "<file delay="${MGL_DELAY[${nextcore}]}" type="${MGL_TYPE[${nextcore}]}" index="${MGL_INDEX[${nextcore}]}" path="\"../../../..${rompath}\""/>" >>/tmp/SAM_game.mgl
	echo "</mistergamedescription>" >>/tmp/SAM_game.mgl

	echo "load_core /tmp/SAM_game.mgl" >/dev/MiSTer_cmd

	sleep 1
	echo "" | >/tmp/.SAM_Joy_Activity
	echo "" | >/tmp/.SAM_Mouse_Activity
	echo "" | >/tmp/.SAM_Keyboard_Activity

	# Skip bios screen for FDS or MegaCD
	skipmessage

}


# ======== ARCADE MODE ========
function build_mralist() {
	if [ "${samquiet}" == "no" ]; then
		echo " Looking for games in  ${1}..."
	else
		echo -n " Looking for games in  ${1}..."
	fi
	# If no MRAs found - suicide!
	find "${1}" -type f \( -iname "*.mra" \) &>/dev/null
	if [ ! ${?} == 0 ]; then
		echo " The path '${1}' contains no MRA files!"
		loop_core
	fi

	# This prints the list of MRA files in a path,
	# Cuts the string to just the file name,
	# Then saves it to the mralist file.

	# If there is an empty exclude list ignore it
	# Otherwise use it to filter the list
	if [ ${#arcadeexclude[@]} -eq 0 ]; then
		find "${1}" -maxdepth 1 -not -path '*/.*' -type f \( -iname "*.mra" \) | cut -c $(($(echo ${#1}) + 2))- >"${mralist}"
	else
		find "${1}" -maxdepth 1 -not -path '*/.*' -type f \( -iname "*.mra" \) | cut -c $(($(echo ${#1}) + 2))- | grep -vFf <(printf '%s\n' ${arcadeexclude[@]}) >"${mralist}"
	fi
	if [ ! -s "${mralist_tmp}" ]; then
		cp "${mralist}" "${mralist_tmp}" &>/dev/null
	fi

	if [ "${samquiet}" == "no" ]; then
		echo "${total_games} Games found."
	else
		echo " ${total_games} Games found."
	fi
}

function load_core_arcade() {

	#DIR=$(echo $(realpath -s --canonicalize-missing "${CORE_PATH[${nextcore}]}${CORE_PATH_EXTRA[${nextcore}]}"))

	# Check if the MRA list is empty or doesn't exist - if so, make a new list

	if [ ! -s "${mralist}" ]; then
		build_mralist 
		[ -f "${mralist_tmp}" ] && rm "${mralist_tmp}"
	fi

	if [ ! -s "${mralist_tmp}" ]; then
		cp "${mralist}" "${mralist_tmp}" &>/dev/null
	fi
	
	# Get a random game from the list
	mra="$(shuf --head-count=1 ${mralist_tmp})"
	MRAPATH="$(echo $(realpath -s --canonicalize-missing "${mra}"))"
	
	if [ ! -f "${MRAPATH}" ]; then
		echo " There is no valid file at ${MRAPATH}... Rebuilding list."
		build_mralist
		[ -f "${mralist_tmp}" ] && rm "${mralist_tmp}"
		cp "${mralist}" "${mralist_tmp}" &>/dev/null
		mra="$(shuf --head-count=1 ${mralist_tmp})"
		MRAPATH="$(echo $(realpath -s --canonicalize-missing "${mra}"))"
	fi

	# If the mra variable is valid this is skipped, but if not we try 5 times
	# Partially protects against typos from manual editing and strange character parsing problems
	for i in {1..5}; do
		if [ ! -f "${MRAPATH}" ]; then
			mra=$(shuf --head-count=1 ${mralist_tmp})
			MRAPATH="$(echo $(realpath -s --canonicalize-missing "${mra}"))"
		fi
	done
	
	#Check blacklist
	if [ -f ${gamelistpath}/${nextcore}_blacklist.txt ]; then
		for i in {1..10}; do
			if [ "$(grep -ic "${mra}" ${gamelistpath}/${nextcore}_blacklist.txt)" != "0"  ]; then
				if [ "${samquiet}" == "no" ]; then echo " Blacklisted because duplicate or boring: ${mra}, trying a different mra.."; fi
				mra=$(shuf --head-count=1 ${mralist_tmp})
				MRAPATH="$(echo $(realpath -s --canonicalize-missing "${mra}"))"
			fi
		done
	fi
	mraname=$(echo $(basename "${mra}") | sed -e 's/\.[^.]*$//')	
	mrasetname=$(grep "<setname>" "${MRAPATH}" | sed -e 's/<setname>//' -e 's/<\/setname>//' | tr -cd '[:alnum:]')
	tty_corename="${mrasetname}"

	if [ "${samquiet}" == "no" ]; then echo " Selected file: ${MRAPATH}"; fi

	# Delete mra from list so it doesn't repeat
	if [ "${norepeat}" == "yes" ]; then
		awk -vLine="$mra" '!index($0,Line)' "${mralist_tmp}" >${tmpfile} && mv ${tmpfile} "${mralist_tmp}"

	fi
	
	if [ "${ttyenable}" == "yes" ]; then
		tty_currentinfo=(
			[core_pretty]="${CORE_PRETTY[${nextcore}]}"
			[name]="{mraname}"
			[core]=${tty_corename}
			[counter]=${gametimer}
			[name_scroll]="${mraname:0:21}"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
		)
		tty_display "${tty_currentinfo}" &
	fi
	echo -n " Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
	echo -e "\e[1m${mraname}\e[0m"
	echo "$(date +%H:%M:%S) - Arcade - ${mraname}" >>/tmp/SAM_Games.log
	echo "${mraname} (${nextcore})" >/tmp/SAM_Game.txt

	mute "${mrasetname}"

	if [ "${1}" == "countdown" ]; then
		for i in {5..1}; do
			echo " Loading game in ${i}...\033[0K\r"
			sleep 1
		done
	fi

	# Tell MiSTer to load the next MRA
	echo "load_core ${MRAPATH}" >/dev/MiSTer_cmd
	sleep 1
	echo "" | >/tmp/.SAM_Joy_Activity
	echo "" | >/tmp/.SAM_Mouse_Activity
	echo "" | >/tmp/.SAM_Keyboard_Activity
	
	if [ "$(find "${gamelistpath}" -name "arcade_gamelist.txt" | wc -l)" == "1" ]; then
	 	nextcore=""
	fi

}

function create_amigalist () {

	if [ -f "${amigapath}/listings/games.txt" ]; then
		[ -f "${amigapath}/listings/games.txt" ] && cat "${amigapath}/listings/demos.txt" > ${gamelistpath}/${nextcore}_gamelist.txt
		sed -i -e 's/^/Demo: /' ${gamelistpath}/${nextcore}_gamelist.txt
		[ -f "${amigapath}/listings/demos.txt" ] && cat "${amigapath}/listings/games.txt" >> ${gamelistpath}/${nextcore}_gamelist.txt
		
		total_games=$(echo $(cat "${gamelistpath}/${nextcore}_gamelist.txt" | sed '/^\s*$/d' | wc -l))

		if [ "${samquiet}" == "no" ]; then
			echo "${total_games} Games and Demos found."
		else
			echo " ${total_games} Games and Demos found."
		fi
	fi

}


function load_core_amiga() {

	amigacore="$(find /media/fat/_Computer/ -iname "*minimig*")"
	
	mute "${CORE_LAUNCH[${nextcore}]}"

	if [ ! -f "${amigapath}/listings/games.txt" ]; then
		# This is for MegaAGS version June 2022 or older
		echo -n " Starting now on the "
		echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
		echo -e "\e[1mMegaAGS Amiga Game\e[0m"

		if [ "${nextcore}" == "countdown" ]; then
			for i in {5..1}; do
				echo " Loading game in ${i}...\033[0K\r"
				sleep 1
			done
		fi

		# Tell MiSTer to load the next MRA

		echo "load_core ${amigacore}" >/dev/MiSTer_cmd
		sleep 13
		"${mrsampath}/mbc" raw_seq {6c
		"${mrsampath}/mbc" raw_seq O
		echo "" | >/tmp/.SAM_Joy_Activity
		echo "" | >/tmp/.SAM_Mouse_Activity
		echo "" | >/tmp/.SAM_Keyboard_Activity
	else
		# This is for MegaAGS version July 2022 or newer
		[ ! -f ${gamelistpath}/${nextcore}_gamelist.txt ] && create_amigalist
		
		if [ ! -s "${gamelistpathtmp}/${nextcore}_gamelist.txt" ]; then
			cp ${gamelistpath}/${nextcore}_gamelist.txt "${gamelistpathtmp}/${nextcore}_gamelist.txt" &>/dev/null
		fi

		rompath="$(shuf --head-count=1 ${gamelistpathtmp}/${nextcore}_gamelist.txt)"
		agpretty="$(echo "${rompath}" | tr '_' ' ')"
		
		# Special case for demo
		if [[ "${rompath}" == *"Demo:"* ]]; then
			rompath=${rompath//Demo: /}
		fi

		# Delete played game from list
		if [ "${samquiet}" == "no" ]; then echo " Selected file: ${rompath}"; fi
		if [ "${norepeat}" == "yes" ]; then
			awk -vLine="$rompath" '!index($0,Line)' "${gamelistpathtmp}/${nextcore}_gamelist.txt" >${tmpfile} && mv ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"
		fi

		echo "${rompath}" > "${amigapath}"/shared/ags_boot
		tty_corename="Minimig"
		
		if [ "${ttyenable}" == "yes" ]; then
			tty_currentinfo=(
			[core_pretty]="${CORE_PRETTY[${nextcore}]}"
			[name]="${agpretty}"
			[core]=${tty_corename}
			[counter]=${gametimer}
			[name_scroll]="${agpretty:0:21}"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
			)
			tty_display "${tty_currentinfo}" &
		fi
		
		

		echo -n " Starting now on the "
		echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
		echo -e "\e[1m${agpretty}\e[0m"
		echo "$(date +%H:%M:%S) - ${nextcore} - ${rompath}" >>/tmp/SAM_Games.log
		echo "${rompath} (${nextcore})" >/tmp/SAM_Game.txt
		#tty_update "${CORE_PRETTY[${nextcore}]}" "${agpretty}" "${CORE_LAUNCH[${nextcore}]}" & # Non blocking Version

		echo "load_core ${amigacore}" >/dev/MiSTer_cmd

	fi
}



# ========= MAIN =========

init_vars

read_samini

init_paths

init_data # Setup data arrays

if [ "${samtrace}" == "yes" ]; then
	debug_output
fi

sam_prep

disable_bootrom # Disable Bootrom until Reboot

mute

if [ "${1,,}" != "--source-only" ]; then
	parse_cmd ${@} # Parse command line parameters for input
fi
