extends "res://Main_Title.gd"

onready var modloader: Reference = get_tree().modloader

func update():
    if self.visible and not Input.is_mouse_button_pressed(BUTTON_LEFT):
        title_loading = false

    if self.patch_time != 0 and not $"/root/Main".demo:
        var time_left = self.patch_time - OS.get_unix_time()
        var patch_text := self.patch_text
        patch_text.raw_string = "<color_6F32A1>v0." + str($"/root/Main".content_patch_num) + "." + str($"/root/Main".hotfix_num) + " (LuckyAPI " + modloader.modloader_version + ")<end>\n<color_E14A68>Mods loaded: <end>" + str(modloader.mod_count) + "\n<color_C71585>" + tr("patch_timer") + "<end>"
        if not $"/root/Main/Options Sprite/Options".CJK_lang:
            patch_text.raw_string += " "
            patch_text.rect_position.y = 62
        else:
            patch_text.rect_position.y = 61
        patch_text.rect_position.y -= 5
        if time_left <= 0:
            patch_text.raw_string += "00" + colon + "00" + colon + "00" + colon + "00"
        else:
            var days = floor(time_left / 86400)
            var hours = int(floor(time_left / 3600)) % 24
            var minutes = int(floor(time_left / 60)) % 60
            var seconds = time_left % 60
            
            if days < 10:
                patch_text.raw_string += "0" + str(days) + colon
            else:
                patch_text.raw_string += str(days) + colon
            
            if hours < 10:
                patch_text.raw_string += "0" + str(hours) + colon
            else:
                patch_text.raw_string += str(hours) + colon
            
            if minutes < 10:
                patch_text.raw_string += "0" + str(minutes) + colon
            else:
                patch_text.raw_string += str(minutes) + colon
            
            if seconds < 10:
                patch_text.raw_string += "0" + str(seconds)
            else:
                patch_text.raw_string += str(seconds)