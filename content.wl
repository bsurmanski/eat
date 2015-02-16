import "libwl/gl.wl"
import "libwl/mesh.wl"
import "libwl/image.wl"
import "libwl/fmt/tga.wl"
import "libwl/fmt/mdl.wl"
import "libwl/file.wl"

undecorated int strcmp(char^ s1, char^ s2);

class MeshNode {
    char[] name
    GLMesh mesh

    MeshNode next

    this(char[] name, GLMesh mesh) {
        .name = name
        .mesh = mesh
    }

    ~this() {
        printf("delete content mesh node\n")
    }
}

class TextureNode {
    char[] name
    GLTexture texture

    TextureNode next

    this(char[] name, GLTexture tex) {
        .name = name
        .texture = tex
    }

    ~this() {
        printf("delete content texture node\n")
    }
}

class Content {
    static Content instance

    MeshNode meshList
    TextureNode textureList

    this() {
    }

    ~this() {
        printf("delete content\n")
    }

    static Content getInstance() {
        if(!instance) {
            instance = new Content()
        }

        return instance
    }

    GLMesh addMesh(char[] name, InputInterface meshInput) {
        Mesh m = loadMdl(meshInput)
        GLMesh mesh = new GLMesh(m)
        MeshNode node = new MeshNode(name, mesh)
        if(.meshList) node.next = .meshList
        .meshList = node
        return mesh 
    }

    GLTexture addTexture(char[] name, InputInterface textureInput) {
        Image i = loadTGA(textureInput)
        GLTexture texture = new GLTexture(i)
        TextureNode node = new TextureNode(name, texture)
        if(.textureList) node.next = .textureList
        .textureList = node
        return texture 
    }

    GLMesh getMesh(char[] name) {
        MeshNode it = .meshList

        while(it) {
            if(name.size == it.name.size) {
                if(strcmp(name.ptr, it.name.ptr) == 0) {
                    return it.mesh
                }
            }
            it = it.next
        }

        return null
    }

    GLTexture getTexture(char[] name) {
        TextureNode it = .textureList

        while(it) {
            if(name.size == it.name.size) {
                if(strcmp(name.ptr, it.name.ptr) == 0) {
                    return it.texture
                }
            }
            it = it.next
        }

        return null
    }
}
