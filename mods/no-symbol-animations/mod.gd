extends Reference

func load(modloader: Reference, mod_info, tree: SceneTree):
    print("No Symbol Animations mod loaded!")

func modify_animation(animation):
    animation.anim_timer = 0