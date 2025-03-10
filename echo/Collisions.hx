package echo;

import echo.Body;
import echo.data.Data;

using Lambda;
/**
 * Class containing methods for performing Collisions on a World
 */
class Collisions {
  /**
   * Queries a World's Listeners for Collisions
   */
  public static function query(world:World) {
    // Populate the Quadtree
    world.quadtree.clear();
    world.quadtree.set(world.x + (world.width * 0.5), world.y + (world.height * 0.5), world.width, world.height);
    world.for_each(b -> {
      b.collided = false;
      for (shape in b.shapes) shape.collided = false;
      if (b.active && b.mass > 0 && (b.x != b.last_x || b.y != b.last_y)) {
        b.bounds(b.cache.quadtree_data.bounds);
        world.quadtree.insert(b.cache.quadtree_data);
      }
    });

    // Process the Listeners
    for (listener in world.listeners.members) {
      // BroadPhase
      listener.quadtree_results.resize(0);
      switch (listener.a) {
        case Left(ba):
          switch (listener.b) {
            case Left(bb):
              var col = body_and_body(ba, bb);
              if (col != null) listener.quadtree_results.push(col);
            case Right(ab):
              body_and_bodies(ba, ab, world, listener.quadtree_results);
          }
        case Right(aa):
          switch (listener.b) {
            case Left(bb):
              body_and_bodies(bb, aa, world, listener.quadtree_results);
            case Right(ab):
              bodies_and_bodies(aa, ab, world, listener.quadtree_results);
          }
      }
      // NarrowPhase
      for (collision in listener.last_collisions) collision.put();
      listener.last_collisions = listener.collisions.copy();
      listener.collisions.resize(0);
      for (result in listener.quadtree_results) {
        // Filterout self collisions/
        if (result.a.id == result.b.id) {
          result.put();
          continue;
        }
        // Filter out duplicate pairs
        var flag = false;
        for (collision in listener.collisions) {
          if (flag) continue;
          if (collision.a.id == result.a.id && collision.b.id == result.b.id) flag = true;
          if (collision.b.id == result.a.id && collision.a.id == result.b.id) flag = true;
        }
        if (flag) {
          result.put();
          continue;
        }
        // Preform the full collision check
        var use_a_cache = result.a.mass == 0;
        var ssa = use_a_cache ? result.a.cache.shapes : result.a.shapes;

        for (sa in ssa) {
          var sac = sa.clone();
          if (use_a_cache) {
            sac.x += result.a.cache.x;
            sac.y += result.a.cache.y;
          }
          else {
            sac.x += result.a.x;
            sac.y += result.a.y;
          }
          var use_b_cache = result.b.mass == 0;
          var ssb = use_b_cache ? result.b.cache.shapes : result.b.shapes;
          for (sb in ssb) {
            var sbc = sb.clone();
            if (use_b_cache) {
              sbc.x += result.b.cache.x;
              sbc.y += result.b.cache.y;
            }
            else {
              sbc.x += result.b.x;
              sbc.y += result.b.y;
            }
            var col = sac.collides(sbc);
            if (col != null) {
              col.sa = sa;
              col.sb = sb;
              result.data.push(col);
            }
            sbc.put();
          }
          sac.put();
        }
        // If there was no collision, continue
        if (result.data.length == 0) {
          result.put();
          continue;
        }
        // Check if the collision passes the listener's condition if it has one
        if (listener.condition != null && !listener.condition(result.a, result.b, result.data)) {
          result.put();
          continue;
        }
        for (data in result.data) data.sa.collided = data.sb.collided = true;
        result.a.collided = result.b.collided = true;
        listener.collisions.push(result);
      }
    }
  }
  /**
   * Enacts the Callbacks defined in a World's Listeners
   */
  public static function notify(world:World) {
    for (listener in world.listeners.members) {
      if (listener.enter != null || listener.stay != null) {
        for (c in listener.collisions) {
          if (listener.enter != null
            && listener.last_collisions.find((f) -> return f.a == c.a && f.b == c.b || f.a == c.b && f.b == c.a) == null) {
            listener.enter(c.a, c.b, c.data);
          }
          else if (listener.stay != null) {
            listener.stay(c.a, c.b, c.data);
          }
        }
      }
      if (listener.exit != null) {
        for (lc in listener.last_collisions) {
          if (listener.collisions.find((f) -> return f.a == lc.a && f.b == lc.b || f.a == lc.b && f.b == lc.a) == null) {
            listener.exit(lc.a, lc.b);
          }
        }
      }
    }
  }

  static function bodies_and_bodies(a:Array<Body>, b:Array<Body>, world:World, results:Array<Collision>) {
    if (a.length == 0 || b.length == 0) return;
    for (body in a) if (body.active && body.mass > 0) body_and_bodies(body, b, world, results);
  }

  static var qr:Array<QuadTreeData> = [];
  static var sqr:Array<QuadTreeData> = [];

  static function body_and_bodies(body:Body, bodies:Array<Body>, world:World, results:Array<Collision>) {
    if (body.shapes.length == 0 || !body.active || body.mass == 0) return;
    var bounds = body.bounds();
    qr.resize(0);
    sqr.resize(0);
    world.quadtree.query(bounds, qr);
    world.static_quadtree.query(bounds, sqr);
    for (member in bodies) {
      for (result in (member.mass > 0 ? qr : sqr)) {
        if (result.id == member.id) results.push(Collision.get(body, member));
      }
    }
    bounds.put();
  }

  static function body_and_body(a:Body, b:Body):Null<Collision> {
    if (a.shapes.length == 0 || b.shapes.length == 0 || !a.active || !b.active || a == b || a.mass == 0 && b.mass == 0) return null;
    var ab = a.bounds();
    var bb = b.bounds();
    var col = ab.collides(bb);
    ab.put();
    bb.put();
    return col == null ? null : Collision.get(a, b);
  }
}
