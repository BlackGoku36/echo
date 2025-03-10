package echo.data;

import echo.Body;
import echo.data.Data;
import echo.data.Types;
import hxmath.math.Vector2;

typedef BodyOptions = {
  /**
   * Defines a Shape that the Body will use as a collider
   */
  var ?shape:ShapeOptions;
  /**
   * Defines an array of Shapes that the Body will use as colliders
   */
  var ?shapes:Array<ShapeOptions>;
  /**
   * Flag to set how a Body is affected by Collisions.
   *
   * If set to true, the Body will still Collide and move through the world, but it will not be moved by external collision forces.
   * This is useful for things like moving platforms.
   */
  var ?kinematic:Bool;
  /**
   * Body's mass. Affects how the Body reacts to Collisions and Velocity.
   *
   * The higher a Body's mass, the more resistant it is to those forces.
   * If a Body's mass is set to `0`, it becomes static - unmovable by forces and collisions.
   */
  var ?mass:Float;
  /**
   * The Body's position on the X axis.
   */
  var ?x:Float;
  /**
   * The Body's position on the Y axis.
   */
  var ?y:Float;
  /**
   * The Body's rotation.
   */
  var ?rotation:Float;
  /**
   * Value to determine how much of a Body's `velocity` should be retained during collisions (or how much should the `Body` "bounce" in other words).
   */
  var ?elasticity:Float;
  /**
   * The units/second that a `Body` moves on the X axis.
   */
  var ?velocity_x:Float;
  /**
   * The units/second that a `Body` moves on the Y axis.
   */
  var ?velocity_y:Float;
  /**
   * The units/second that a `Body` will rotate. Currently is not Implemented.
   */
  var ?rotational_velocity:Float;
  /**
   * The maximum velocity range that a `Body` can have on the X axis.
   *
   * If set to 0, the Body has no restrictions on how fast it can move.
   */
  var ?max_velocity_x:Float;
  /**
   * The maximum velocity range that a `Body` can have on the Y axis.
   *
   * If set to 0, the Body has no restrictions on how fast it can move.
   */
  var ?max_velocity_y:Float;
  /**
   * The maximum rotational velocity range that a `Body` can have. Currently not Implemented.
   *
   * If set to 0, the Body has no restrictions on how fast it can rotate.
   */
  var ?max_rotational_velocity:Float;
  /**
   * A measure of how fast a Body will move its velocity towards 0 on the X axis when there is no acceleration.
   */
  var ?drag_x:Float;
  /**
   * A measure of how fast a Body will move its velocity towards 0 on the Y axis when there is no acceleration.
   */
  var ?drag_y:Float;

  var ?gravity_scale:Float;
}

typedef WorldOptions = {
  /**
   * Width of the World, extending right from the World's X position.
   */
  var width:Float;
  /**
   * Height of the World, extending down from the World's Y position.
   */
  var height:Float;
  /**
   * The World's position on the X axis.
   */
  var ?x:Float;
  /**
   * The World's position on the Y axis.
   */
  var ?y:Float;
  /**
   * The amount of acceleration on the X axis applied to each `Body` member every Step.
   */
  var ?gravity_x:Float;
  /**
   * The amount of acceleration on the Y axis applied to each `Body` member every Step.
   */
  var ?gravity_y:Float;

  var ?members:Array<Body>;
  var ?listeners:Array<Listener>;
  /**
   * The amount of iterations that occur each time the World is stepped. The higher the number, the more stable the Physics Simulation will be, at the cost of performance.
   */
  var ?iterations:Int;

  var ?history:Int;
}

typedef ListenerOptions = {
  /**
   * Flag that determines if Collisions found by this listener should separate the Bodies. Defaults to `true`.
   */
  var ?separate:Bool;
  /**
   * A callback function that is called on the first frame that a collision starts.
   */
  var ?enter:Body->Body->Array<CollisionData>->Void;
  /**
   * A callback function that is called on frames when two Bodies are continuing to collide.
   */
  var ?stay:Body->Body->Array<CollisionData>->Void;
  /**
   * A callback function that is called when a collision between two Bodies ends.
   */
  var ?exit:Body->Body->Void;
  /**
   * A callback function that allows extra logic to be run on a potential collision.
   *
   * If it returns true, the collision is valid. Otherwise the collision is discarded and no physics resolution/collision callbacks occur
   */
  var ?condition:Body->Body->Array<CollisionData>->Bool;
  /**
   * Percentage of correction along the collision normal to be applied to seperating bodies. Helps prevent objects sinking into each other.
   */
  var ?percent_correction:Float;
  /**
   * Threshold determining how close two separating bodies must be before position correction occurs. Helps reduce jitter.
   */
  var ?correction_threshold:Float;
}

typedef ShapeOptions = {
  /**
   * Enum describing the Shape to create. Currently supports RECT and CIRCLE.
   */
  var ?type:ShapeType;

  var ?solid:Bool;
  /**
   * If the Shape is a Circle, it's radius will be taken from this value. Otherwise this is ignored.
   */
  var ?radius:Float;
  /**
   * If the Shape is a Rect, it's width will be taken from this value. Otherwise this is ignored.
   *
   * If this value is set and height isnt, the Rect will use this value for it's height.
   */
  var ?width:Float;
  /**
   * If the Shape is a Rect, it's height will be taken from this value. Otherwise this is ignored.
   *
   * If this value isnt set and width isnt, the Rect will use its width value for it's height.
   */
  var ?height:Float;

  var ?points:Array<Vector2>;
  var ?rotation:Float;
  /**
   * The Shape's offset from it's parent Body on the X-Axis.
   */
  var ?offset_x:Float;
  /**
   * The Shape's offset from it's parent Body on the Y-Axis.
   */
  var ?offset_y:Float;
}

typedef RectOptions = {
  var x:Float;
  var y:Float;
  var width:Float;
  var height:Float;
}

typedef CircleOptions = {
  var x:Float;
  var y:Float;
  var radius:Float;
}

typedef PolygonOptions = {
  var x:Float;
  var y:Float;
  var vertices:Array<Vector2>;
  var rotation:Float;
}

typedef RayOptions = {
  var x:Float;
  var y:Float;
  var dx:Float;
  var dy:Float;
}
