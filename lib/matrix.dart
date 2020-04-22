// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Class building a rotation matrix for rotations about the line through (a, b, c)
/// parallel to [u, v, w] by the angle theta.
///
/// Original implementation in Java by Glenn Murray
/// available online on https://sites.google.com/site/glennmurray/Home/rotation-matrices-and-formulas
class RotationMatrix {
  static const TOLERANCE = 1E-9;
  Float64List _matrix;

  num m11;
  num m12;
  num m13;
  num m14;
  num m21;
  num m22;
  num m23;
  num m24;
  num m31;
  num m32;
  num m33;
  num m34;

  /// Build a rotation matrix for rotations about the line through (a, b, c)
  /// parallel to [u, v, w] by the angle theta.
  ///
  /// [a] x-coordinate of a point on the line of rotation.
  /// [b] y-coordinate of a point on the line of rotation.
  /// [c] z-coordinate of a point on the line of rotation.
  /// [uUn] x-coordinate of the line's direction vector (unnormalized).
  /// [vUn] y-coordinate of the line's direction vector (unnormalized).
  /// [wUn] z-coordinate of the line's direction vector (unnormalized).
  /// [theta] The angle of rotation, in radians.
  RotationMatrix(num a, num b, num c, num uUn, num vUn, num wUn, num theta) {
    num l;
    assert((l = _longEnough(uUn, vUn, wUn)) > 0,
        'RotationMatrix: direction vector too short!');

    // In this instance we normalize the direction vector.
    num u = uUn / l;
    num v = vUn / l;
    num w = wUn / l;

    // Set some intermediate values.
    num u2 = u * u;
    num v2 = v * v;
    num w2 = w * w;
    num cosT = math.cos(theta);
    num oneMinusCosT = 1 - cosT;
    num sinT = math.sin(theta);

    // Build the matrix entries element by element.
    m11 = u2 + (v2 + w2) * cosT;
    m12 = u * v * oneMinusCosT - w * sinT;
    m13 = u * w * oneMinusCosT + v * sinT;
    m14 = (a * (v2 + w2) - u * (b * v + c * w)) * oneMinusCosT +
        (b * w - c * v) * sinT;

    m21 = u * v * oneMinusCosT + w * sinT;
    m22 = v2 + (u2 + w2) * cosT;
    m23 = v * w * oneMinusCosT - u * sinT;
    m24 = (b * (u2 + w2) - v * (a * u + c * w)) * oneMinusCosT +
        (c * u - a * w) * sinT;

    m31 = u * w * oneMinusCosT - v * sinT;
    m32 = v * w * oneMinusCosT + u * sinT;
    m33 = w2 + (u2 + v2) * cosT;
    m34 = (c * (u2 + v2) - w * (a * u + b * v)) * oneMinusCosT +
        (a * v - b * u) * sinT;
  }

  /// Multiply this [RotationMatrix] times the point (x, y, z, 1),
  /// representing a point P(x, y, z) in homogeneous coordinates.  The final
  /// coordinate, 1, is assumed.
  ///
  /// [x] The point's x-coordinate.
  /// [y] The point's y-coordinate.
  /// [z] The point's z-coordinate.
  ///
  /// Returns the product, in a [Vector3], representing the
  /// rotated point.
  List<num> timesXYZ(num x, num y, num z) {
    final p = [0.0, 0.0, 0.0];

    p[0] = m11 * x + m12 * y + m13 * z + m14;
    p[1] = m21 * x + m22 * y + m23 * z + m24;
    p[2] = m31 * x + m32 * y + m33 * z + m34;

    return p;
  }

  /// Compute the rotated point from the formula given in the paper, as opposed
  /// to multiplying this matrix by the given point. Theoretically this should
  /// give the same answer as [timesXYZ]. For repeated
  /// calculations this will be slower than using [timesXYZ]
  /// because, in effect, it repeats the calculations done in the constructor.
  ///
  /// This method is static partly to emphasize that it does not
  /// mutate an instance of [RotationMatrix], even though it uses
  /// the same parameter names as the the constructor.
  ///
  /// [a] x-coordinate of a point on the line of rotation.
  /// [b] y-coordinate of a point on the line of rotation.
  /// [c] z-coordinate of a point on the line of rotation.
  /// [u] x-coordinate of the line's direction vector.  This direction
  ///          vector will be normalized.
  /// [v] y-coordinate of the line's direction vector.
  /// [w] z-coordinate of the line's direction vector.
  /// [x] The point's x-coordinate.
  /// [y] The point's y-coordinate.
  /// [z] The point's z-coordinate.
  /// [theta] The angle of rotation, in radians.
  ///
  /// Returns the product, in a [Vector3], representing the
  /// rotated point.
  static List<num> rotPointFromFormula(num a, num b, num c, num u, num v, num w,
      num x, num y, num z, num theta) {
    // We normalize the direction vector.

    num l;
    if ((l = _longEnough(u, v, w)) < 0) {
      print("RotationMatrix direction vector too short");
      return null; // Don't bother.
    }
    // Normalize the direction vector.
    u = u / l; // Note that is not "this.u".
    v = v / l;
    w = w / l;
    // Set some intermediate values.
    num u2 = u * u;
    num v2 = v * v;
    num w2 = w * w;
    num cosT = math.cos(theta);
    num oneMinusCosT = 1 - cosT;
    num sinT = math.sin(theta);

    // Use the formula in the paper.
    final p = [0.0, 0.0, 0.0];
    p[0] = (a * (v2 + w2) - u * (b * v + c * w - u * x - v * y - w * z)) *
            oneMinusCosT +
        x * cosT +
        (-c * v + b * w - w * y + v * z) * sinT;

    p[1] = (b * (u2 + w2) - v * (a * u + c * w - u * x - v * y - w * z)) *
            oneMinusCosT +
        y * cosT +
        (c * u - a * w + w * x - u * z) * sinT;

    p[2] = (c * (u2 + v2) - w * (a * u + b * v - u * x - v * y - w * z)) *
            oneMinusCosT +
        z * cosT +
        (-b * u + a * v - v * x + u * y) * sinT;

    return p;
  }

  /// Check whether a vector's length is less than [TOLERANCE].
  ///
  /// [u] The vector's x-coordinate.
  /// [v] The vector's y-coordinate.
  /// [w] The vector's z-coordinate.
  ///
  /// Returns length = math.sqrt(u^2 + v^2 + w^2) if it is greater than
  /// [TOLERANCE], or -1 if not.
  static num _longEnough(num u, num v, num w) {
    num l = math.sqrt(u * u + v * v + w * w);
    if (l > TOLERANCE) {
      return l;
    } else {
      return -1;
    }
  }

  /// Get the resulting matrix.
  ///
  /// Returns The matrix as [Matrix4].
  Float64List getMatrix() {
    if (_matrix == null) {
      _matrix = Float64List.fromList([
        m11,
        m21,
        m31,
        0,
        m12,
        m22,
        m32,
        0,
        m13,
        m23,
        m33,
        0,
        m14,
        m24,
        m34,
        1
      ]);
      // matrix = Matrix4.columns(
      //   Vector4(m11, m21, m31, 0),
      //   Vector4(m12, m22, m32, 0),
      //   Vector4(m13, m23, m33, 0),
      //   Vector4(m14, m24, m34, 1),
      // );
    }
    return _matrix;
  }
}
