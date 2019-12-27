Map Map;

static class GAME
{
    static Boolean editMode = true;
    static Boolean playMode = false;
    static Boolean mouseHeld = false;
    static Boolean drawMode = false;

    static Boolean hasStartTile = false;
    static Boolean hasEndTile = false;

    static Boolean creatingEnemyPath = false;
    static Map.Enemy creatingEnemyPathEnemy;
}

static class MOUSE
{
    
}

void setup() {
    frameRate(60);
    size(801, 451);
    Map = new Map(
        new PVector(16, 9)
    );
}

void draw() {
    background(0);

    frame();

    Map.render();
}

public class Map
{
    PVector size, tile_size;
    Tile[][] tiles;

    Player Player;
    ArrayList<Enemy> enemys = new ArrayList<Enemy>();
    public Map(PVector size) {
        this.size  = size;
        this.tiles = new Tile[floor(size.x)][floor(size.y)];
        this.tile_size = new PVector((width-1)/size.x, (height-1)/size.y);
        for (int i = 0; i < size.x; i++) {
            for (int j = 0; j < size.y; j++) {
                this.tiles[i][j] = new Tile(
                    new PVector(i, j),
                    new PVector(tile_size.x*i, tile_size.y*j),
                    tile_size
                );
            }
        }
    }

    public class Tile {
        Boolean state    = false,
                isStart  = false,
                isFinish = false,
                isCheck  = false;
        Boolean[] walls = { false, false, false, false };
        PVector apos, rpos, size;

        public Tile(PVector apos, PVector rpos, PVector size) {
            this.apos = apos;
            this.rpos = rpos;
            this.size = size;
        }

        void render() {
            if (this.isStart) {
                fill(200, 255, 200);
            } else if (this.isFinish) {
                fill(255, 125, 125);
            } else if (this.isCheck) {
                fill(150, 150, 255);
            } else if (!this.state) {
                fill(200, 200, 255);
            } else {
                fill(255, 253, 208);
            } noStroke(); strokeWeight(1);
            rect(this.rpos.x, this.rpos.y, this.size.x, this.size.y);
        }

        void renderWalls() {
            fill(0); stroke(0); strokeWeight(3);
            if (this.walls[0]) { line(this.rpos.x, this.rpos.y, this.rpos.x+this.size.x, this.rpos.y); }
            if (this.walls[1]) { line(this.rpos.x+this.size.x, this.rpos.y, this.rpos.x+this.size.x, this.rpos.y+this.size.y); }
            if (this.walls[2]) { line(this.rpos.x, this.rpos.y+this.size.y, this.rpos.x+this.size.x, this.rpos.y+this.size.y); }
            if (this.walls[3]) { line(this.rpos.x, this.rpos.y, this.rpos.x, this.rpos.y+this.size.y); }
        }

        void checkWalls() {
            try { if (Map.tiles[int(this.apos.x)][int(this.apos.y)-1].state == false) { this.walls[0] = true; } else { this.walls[0] = false; } } catch(ArrayIndexOutOfBoundsException ex) { this.walls[0] = true; }
            try { if (Map.tiles[int(this.apos.x)+1][int(this.apos.y)].state == false) { this.walls[1] = true; } else { this.walls[1] = false; } } catch(ArrayIndexOutOfBoundsException ex) { this.walls[1] = true; }
            try { if (Map.tiles[int(this.apos.x)][int(this.apos.y)+1].state == false) { this.walls[2] = true; } else { this.walls[2] = false; } } catch(ArrayIndexOutOfBoundsException ex) { this.walls[2] = true; }
            try { if (Map.tiles[int(this.apos.x)-1][int(this.apos.y)].state == false) { this.walls[3] = true; } else { this.walls[3] = false; } } catch(ArrayIndexOutOfBoundsException ex) { this.walls[3] = true; }
        }
    }

    public class Enemy {
        PVector pos, size;
        ArrayList<PVector> path = new ArrayList<PVector>();
        Integer pathIndx = 0;

        Enemy(PVector pos, PVector size) { {
            this.pos = pos; this.size = size;
        }

        }

        void render() {
            fill(255, 100, 100); stroke(0);
            rect(this.pos.x, this.pos.y, this.size.x, this.size.y);
        }
    }

    public class Player{
        PVector pos, size;

        Player(PVector pos, PVector size) {
            this.pos = pos; this.size = size;
        }

        void render() {
            fill(255, 0, 0); stroke(0);
            rect(this.pos.x, this.pos.y, this.size.x, this.size.y);
        }
    }

    void render() {
        for (Tile[] tarr : this.tiles) { for (Tile t : tarr) {
            t.render();
        } }
        for (Tile[] tarr : this.tiles) { for (Tile t : tarr) {
            if (t.state) {
                t.renderWalls();
            }
        } }

        for (int i = this.enemys.size()-1; i >= 0; i--) {
            this.enemys.get(i).render();
            for (PVector pv : this.enemys.get(i).path) {
                fill(255, 100, 100); stroke(0, 0);
                ellipse(pv.x*this.tile_size.x+this.tile_size.x/2, pv.y*this.tile_size.y+this.tile_size.y/2, 10, 10);
            }
        }

        if (GAME.playMode) {
            this.Player.render();
        }
    }

    void checkWalls() {
        for (Tile[] tarr : this.tiles) { for (Tile t : tarr) {
            t.checkWalls();
        } }
    }

    void createEnemy(PVector mpos) {
        Enemy e = new Enemy(
            new PVector(
                mpos.x*this.tile_size.x+this.tile_size.x/4,
                mpos.y*this.tile_size.y+this.tile_size.y/4
            ),
            new PVector(
                this.tile_size.x/2,
                this.tile_size.y/2
            )
        );
        e.path.add(mpos);

        this.enemys.add(e);
        GAME.creatingEnemyPathEnemy = e;
        GAME.creatingEnemyPath = true;
    }

    void createPlayer() {
        Tile tile = null;
        for (Tile[] tarr : this.tiles) { for (Tile t : tarr) {
            if (t.isStart) {
                tile = t;
            }
        } }

        this.Player = new Player(
            new PVector(tile.rpos.x+this.tile_size.x/3, tile.rpos.y+this.tile_size.y/3),
            new PVector(this.tile_size.x/3, this.tile_size.y/3)
        );
    }

    void play() {
        if (GAME.hasStartTile == false) {
            return;
        }
        if (GAME.hasEndTile == false) {
            return;
        }

        this.createPlayer();
        GAME.editMode = false;
        GAME.playMode = true;
    }

    void edit() {
        this.Player = null;
        GAME.editMode = true;
        GAME.playMode = false;
    }
}

PVector getVectorMPos(PVector mpos) {
    return new PVector(floor(mpos.x/Map.tile_size.x),
                       floor(mpos.y/Map.tile_size.y));
}

void frame() {
    // EDIT
    if (GAME.editMode) {
        PVector mPos = getVectorMPos(new PVector(mouseX, mouseY));
        if (GAME.mouseHeld) {
            try {
                Map.Tile tile = Map.tiles[int(mPos.x)][int(mPos.y)];
                tile.state = GAME.drawMode;
                if (GAME.drawMode == false) {
                    if (tile.isStart) {
                        GAME.hasStartTile = false;
                        tile.isStart = false;
                    }
                    if (tile.isFinish) {
                        GAME.hasEndTile = false;
                        tile.isFinish = false;
                    }
                    tile.isCheck = false;
                }
                Map.checkWalls();
            } catch (ArrayIndexOutOfBoundsException aioobe) { }
        }
    }
    // PLAY
    if (GAME.playMode) {

    }
}

void mousePressed() {
    if (GAME.creatingEnemyPath) {
        if (mouseButton == LEFT) {
            GAME.creatingEnemyPathEnemy.path.add(getVectorMPos(new PVector(mouseX, mouseY)));
        } else if (mouseButton == RIGHT) {
            GAME.creatingEnemyPath = false;
            GAME.creatingEnemyPathEnemy = null;
        }
    } else if (GAME.editMode && mouseButton == LEFT) { GAME.mouseHeld = true;
        PVector mpos = getVectorMPos(new PVector(mouseX, mouseY));
        if(!Map.tiles[int(mpos.x)][int(mpos.y)].state) {
            GAME.drawMode = true;
        } else {
            GAME.drawMode = false;
        }
    }
}

void mouseReleased() {
    if (GAME.editMode && mouseButton == LEFT) { GAME.mouseHeld = false; }
}

void keyPressed() {
    PVector mpos = getVectorMPos(new PVector(mouseX, mouseY));
    // println(mpos); println(Map.size);
    if (mpos.x <  0          || mpos.y <  0)          { return; }
    if (mpos.x >= Map.size.x || mpos.y >= Map.size.y) { return; }

    if (GAME.editMode && GAME.creatingEnemyPath == false) {
        if (key == 'z') {
            // println("Z");
            if (GAME.hasStartTile == false) {
                GAME.hasStartTile = true;
                Map.tiles[int(mpos.x)][int(mpos.y)].state = true;
                Map.tiles[int(mpos.x)][int(mpos.y)].isStart = true;
            }
        } else if (key == 'x') {
            // println("X");
            if (GAME.hasEndTile == false) {
                GAME.hasEndTile = true;
                Map.tiles[int(mpos.x)][int(mpos.y)].state = true;
                Map.tiles[int(mpos.x)][int(mpos.y)].isFinish = true;
            }
        } else if (key == 'c') {
            // println("C");
            Map.tiles[int(mpos.x)][int(mpos.y)].state = true;
            Map.tiles[int(mpos.x)][int(mpos.y)].isCheck = true;
        } else if (key == 'e') {
            Map.createEnemy(mpos);
        } else if (key == 'p') {
            Map.play();
        }
        Map.checkWalls();
    }
    else if (GAME.playMode) {
        Map.edit();
    }
}