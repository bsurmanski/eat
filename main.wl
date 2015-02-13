//XXX it errors if out of order
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_mixer.h"
import(C) "port.h"
import "libwl/image.wl"
import "libwl/fmt/tga.wl"
import "libwl/file.wl"
import "libwl/gl.wl"
import "libwl/sdl.wl"
import "libwl/mesh.wl"
import "libwl/fmt/mdl.wl"
import "libwl/collision.wl"
import "libwl/random.wl"
import "libwl/vec.wl"
import "cookie.wl"
import "grub.wl"
import "mouse.wl"
import "music.wl"
import "crumb.wl"
import "entity.wl"
import "carrot.wl"
import "cliffbar.wl"
import "girl.wl"
import "shroom.wl"

import "drawDevice.wl"

import "scene.wl"
import "man.wl"
import "title.wl"


undecorated int printf(char^ fmt, ...);

const int TITLE = 0
const int INSTRUCTIONS = 1
const int GAME = 2
const int WIN = 3
const int LOSE = 4
bool running = true
GLDrawDevice glDevice
GLTexture tex

int whereAreWe= 0

Cookie cookie

DuckMan man
Title title
mat4 view

GLMesh house_inside_mesh
GLTexture house_inside_tex

GLTexture instructions
GLTexture win
GLTexture lose

//int WIDTH = 640
//int HEIGHT = 480

int WIDTH = 960
int HEIGHT = 720
void init() {
    SDLWindow window = new SDLWindow(WIDTH, HEIGHT, "Who Ate Cookies?")
    Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, 2, 2048)
    Image i = loadTGA(new StringFile(pack "res/test.tga"))
    tex = new GLTexture(i)
    glDevice = new GLDrawDevice(WIDTH, HEIGHT)
    man = new DuckMan()
    title = new Title()

    i = loadTGA(new StringFile(pack "res/instructions.tga"))
    instructions = new GLTexture(i)
    i = loadTGA(new StringFile(pack "res/win.tga"))
    win = new GLTexture(i)
    i = loadTGA(new StringFile(pack "res/lose.tga"))
    lose = new GLTexture(i)

    loadScene(new StringFile(pack "mouse.scn"))

    musicInit()

    i = loadTGA(new StringFile(pack "res/house_inside.tga"))
    house_inside_tex = new GLTexture(i)
    Mesh m = loadMdl(new StringFile(pack "res/house_inside.mdl"))
    house_inside_mesh = new GLMesh(m)
}

void input() {
    SDL_PumpEvents()

    //XXX hack because SDL_Event is a union which wlc currently doesnt support
    char[128] event
    while(SDL_PollEvent(void^: event.ptr)) {
        if(event[0] == SDL_QUIT) {
            running = false
        }
    }

    uint8^ keystate = SDL_GetKeyState(null)

    static bool SPACE_DOWN
    static bool X_DOWN
    static bool Z_DOWN
    static bool Q_DOWN

    if(keystate[SDLK_c]) man.scale = 1.2
    if(keystate[SDLK_ESCAPE]) {
        running = false
    }

    if(whereAreWe == TITLE) {
        if(keystate[SDLK_SPACE] and !SPACE_DOWN) {
            whereAreWe = INSTRUCTIONS 
        }
    } else if(whereAreWe == INSTRUCTIONS) {
        if(keystate[SDLK_SPACE] and !SPACE_DOWN) {
            whereAreWe = GAME
            // this is here so that music messes with random seed
            initMice()
            initGrubs()
            initCrumbs()
            initCarrots()
            initCliffbars()
            Entity.add(new GirlDuck())
            //(Entity.add(new Shroom()))
        }
    } else if(whereAreWe == GAME) {
        if(keystate[SDLK_LEFT]) {
            man.rotate(0.25)
        }

        if(keystate[SDLK_RIGHT]) {
            man.rotate(-0.25)
        }

        if(keystate[SDLK_UP]) {
            man.step()
        }
    } else if(whereAreWe == LOSE) {
        if(keystate[SDLK_SPACE]) {
            man.reset()
            Entity.removeAll()
            whereAreWe = TITLE
        }
    } else if(whereAreWe == WIN) {
            if(keystate[SDLK_SPACE]) {
                man.reset()
                whereAreWe = TITLE
            }
    }

    GLDrawDevice dev = GLDrawDevice.getInstance()
    if(keystate[SDLK_x] and !X_DOWN) {
        dev.crazy = !dev.crazy
    } 

    if(keystate[SDLK_z] and !Z_DOWN) {
        dev.boring = !dev.boring
    }

    if(keystate[SDLK_q] and !Q_DOWN) {
        dev.drawHitbox = !dev.drawHitbox
    }

    SPACE_DOWN = keystate[SDLK_SPACE]
    X_DOWN = keystate[SDLK_x]
    Z_DOWN = keystate[SDLK_z]
    Q_DOWN = keystate[SDLK_q]
}

void update(float dt) {
    glDevice.update(dt)
    if(whereAreWe == TITLE) {
        title.update(dt)
    } else if(whereAreWe == GAME) {
        man.update(dt)
        if(man.isDead()) {
            whereAreWe = LOSE
        }

        updateEntities(dt)

        Entity first = Entity.getFirst()
        if(!first) {
            if(!cookie) {
                cookie = new Cookie()
                cookie.position = vec4(0, 15, 0, 0)
            }
            static float cookie_v
            if(cookie.position.v[1] > 1.0f) {
                cookie_v -= 0.02
                cookie.position.v[1] += cookie_v
            } else {
                cookie_v *= -0.7
                cookie.position.v[1] = 1.01f
            }

            cookie.update(dt)

            if(cookie.isDead()) {
                whereAreWe = WIN
                cookie = null
            }
        }

        view = mat4()
        view = view.translate(vec4(-man.position.v[0], 
                                -6.0f * man.scale - 1, 
                                -8.0f * man.scale - man.position.v[2] - 1, 0))
        view = view.rotate(0.5, vec4(1, 0, 0, 0))
    }

    if(!man.isDead()) {
        float musicDt = dt
        if(man.nummyTimer > 0) musicDt *=2
        musicUpdate(musicDt)
    }
}

void draw_house() {
    glDevice.cullFaces(true)
    glDevice.runMeshProgram(house_inside_mesh, house_inside_tex, view)
    glDevice.cullFaces(false)
}

void draw() {
    glDevice.clearBuffer()
    glDevice.clear()
    tex.bind()
    if(whereAreWe == TITLE) {
        title.draw()
    } else if(whereAreWe == INSTRUCTIONS) {
        glDevice.runTitleProgram(glDevice.getQuad(), instructions, mat4())
    } else if(whereAreWe == GAME) {
        draw_house()
        man.draw(view)

        drawEntities(view)

        if(cookie) {
            cookie.draw(view)
        }
    } else if(whereAreWe == WIN) {
        glDevice.runTitleProgram(glDevice.getQuad(), win, mat4())
    } else if(whereAreWe == LOSE) {
        glDevice.runTitleProgram(glDevice.getQuad(), lose, mat4())
    }

    glDevice.drawQuad()


    SDL_GL_SwapBuffers()
}

int main(int argc, char^^ argv) 
{
    static uint ticks
    static uint lastTicks
    init()
    float dt = 0
    while(running) {
        input()
        update(dt)
        draw()
        ticks = SDL_GetTicks()
        if(32 - (ticks - lastTicks) > 0) {
        SDL_Delay(32 - (ticks - lastTicks))
        }
        dt = 0.032;
        lastTicks = SDL_GetTicks()
    }

    return 0
}
