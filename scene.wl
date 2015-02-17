import "libwl/file.wl"
import "libwl/vec.wl"
import "entity.wl"
import "content.wl"
import "mouse.wl"

import "libwl/gl.wl"
import "libwl/image.wl"
import "libwl/fmt/tga.wl"

class Scene {
    this() {
    }
}

struct SceneHeader {
    char[3] magic
    uint8 version
    uint16 nentities
    char[10] padding
    char[16] name
}

struct SceneEntity {
    uint16 pid
    char[6] padding1
    float[3] position
    float[3] scale
    float[4] rotation
    char[16] name
}

undecorated int printf(char^ fmt, ...);
undecorated int strcmp(void^ v1, void^ v2);

Scene loadScene(InputInterface file) {
    SceneHeader head
    file.read(&head, SceneHeader.sizeof, 1)
    if( head.magic[0] != 'S' or
        head.magic[1] != 'C' or
        head.magic[2] != 'N') {
        printf("ERROR: invalid SCN file format\n")
    }

    Scene scene = new Scene()
    for(int i = 0; i < head.nentities; i++) {
        SceneEntity ent
        file.read(&ent, SceneEntity.sizeof, 1)
        vec4 position = vec4(ent.position[0], ent.position[1], ent.position[2], 1)
        vec4 rotation = vec4(ent.rotation[0], ent.rotation[1], ent.rotation[2], ent.rotation[3])
        vec4 scale = vec4(ent.scale[0], ent.scale[1], ent.scale[2], 1)

        if(!strcmp("Mouse".ptr, ent.name.ptr)) {
            Mouse m = new Mouse()
            m.position = position
            m.qrotation = rotation
            Entity.add(m)
        } else if(!strcmp("Camera".ptr, ent.name.ptr)) {
        } else if(!strcmp("Lamp".ptr, ent.name.ptr)) {
        } else {
            Content content = Content.getInstance()
            Entity e = new Entity()
            if(!strcmp("sidetable".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("sidetable")
                e.someTexture = content.getTexture("sidetable")
            } else if(!strcmp("jar".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("jar")
                e.someTexture = content.getTexture("jam")
            } else if(!strcmp("flowerpot".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("flowerpot")
                e.someTexture = content.getTexture("flowerpot")
            } else if(!strcmp("Tulip".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("tulip")
                e.someTexture = content.getTexture("tulip")
            }
            else if(!strcmp("toast".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("toast")
                e.someTexture = content.getTexture("toast")
            } else if(!strcmp("toaster".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("toaster")
                e.someTexture = content.getTexture("toaster")
            } else if(!strcmp("counter".ptr, ent.name.ptr)) {
                e.someMesh = content.getMesh("counter")
                e.someTexture = content.getTexture("counter")
            } else {
                continue
            }
            e.position = position
            e.qrotation = rotation
            e.scale = scale
            Entity.add(e)
        }
    }
    return scene
}
