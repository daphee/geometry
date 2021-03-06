--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- This Source Code Form is subject to the terms of the Mozilla Public        --
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,  --
-- you can obtain one at http://mozilla.org/MPL/2.0/.                         --
--                                                                            --
-- Copyright 2016 by Ian Mackenzie                                            --
-- ian.e.mackenzie@gmail.com                                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


module OpenSolid.BoundingBox3d
    exposing
        ( BoundingBox3d
        , centroid
        , contains
        , dimensions
        , extrema
        , hull
        , hullOf
        , intersection
        , isContainedIn
        , maxX
        , maxY
        , maxZ
        , midX
        , midY
        , midZ
        , minX
        , minY
        , minZ
        , overlaps
        , singleton
        , with
        )

{-| <img src="https://opensolid.github.io/images/geometry/icons/boundingBox3d.svg" alt="BoundingBox3d" width="160">

A `BoundingBox3d` is a rectangular box in 3D defined by its minimum and maximum
X, Y and Z values. It is possible to generate bounding boxes for most geometric
objects; for example, [`Triangle3d.boundingBox`](OpenSolid-Triangle3d#boundingBox)
takes a `Triangle3d` and returns a `BoundingBox3d` that contains that triangle.
There are several use cases where it is more efficient to deal with the bounding
box of an object than the object itself, such as:

  - Intersection checking: If (for example) the bounding boxes of a line segment
    and a triangle do not overlap, then the line segment and triangle cannot
    possibly intersect each other. Expensive intersection checking therefore
    only has to be performed for line segments and triangles whose bounding
    boxes _do_ overlap.
  - 3D rendering: When rendering a 3D scene, any object whose bounding box is
    not visible must itself be not visible, and therefore does not have to be
    drawn. This provides a simple form of culling.

@docs BoundingBox3d


# Constructors

@docs with, singleton, hull, intersection, hullOf


# Properties

@docs extrema, minX, maxX, minY, maxY, minZ, maxZ, dimensions, midX, midY, midZ, centroid


# Queries

@docs contains, overlaps, isContainedIn

-}

import OpenSolid.Bootstrap.BoundingBox3d as Bootstrap
import OpenSolid.Bootstrap.Point3d as Point3d
import OpenSolid.Geometry.Internal as Internal exposing (Point3d)


{-| -}
type alias BoundingBox3d =
    Internal.BoundingBox3d


{-| Construct a bounding box from its minimum and maximum X, Y and Z values:

    exampleBox =
        BoundingBox3d.with
            { minX = -2
            , maxX = 2
            , minY = 2
            , maxY = 5
            , minZ = 3
            , maxZ = 4
            }

If the minimum and maximum values are provided in the wrong order (for example
if <code>minX&nbsp;>&nbsp;maxX</code>), then they will be swapped so that the
resulting bounding box is valid.

-}
with : { minX : Float, maxX : Float, minY : Float, maxY : Float, minZ : Float, maxZ : Float } -> BoundingBox3d
with =
    Bootstrap.with


{-| Construct a zero-width bounding box containing a single point.

    point =
        Point3d.fromCoordinates ( 2, 1, 3 )

    BoundingBox3d.singleton point
    --> BoundingBox3d.with
    -->     { minX = 2
    -->     , maxX = 2
    -->     , minY = 1
    -->     , maxY = 1
    -->     , minZ = 3
    -->     , maxZ = 3
    -->     }

-}
singleton : Point3d -> BoundingBox3d
singleton point =
    let
        ( x, y, z ) =
            Point3d.coordinates point
    in
    with
        { minX = x
        , maxX = x
        , minY = y
        , maxY = y
        , minZ = z
        , maxZ = z
        }


{-| Construct a bounding box containing all bounding boxes in the given list. If
the list is empty, returns `Nothing`.

    singletonBox =
        BoundingBox3d.singleton
            (Point3d.fromCoordinates ( 2, 1, 0 ))

    BoundingBox3d.hullOf [ exampleBox, singletonBox ]
    --> Just
    -->     (BoundingBox3d.with
    -->         { minX = -2,
    -->         , maxX = 2
    -->         , minY = 1
    -->         , maxY = 5
    -->         , minZ = 0
    -->         , maxZ = 4
    -->         }
    -->     )

    BoundingBox3d.hullOf [ exampleBox ]
    --> Just exampleBox

    BoundingBox3d.hullOf []
    --> Nothing

If you have exactly two bounding boxes, you can use [`BoundingBox3d.hull`](#hull)
instead (which returns a `BoundingBox3d` instead of a `Maybe BoundingBox3d`).

-}
hullOf : List BoundingBox3d -> Maybe BoundingBox3d
hullOf boundingBoxes =
    case boundingBoxes of
        first :: rest ->
            Just (List.foldl hull first rest)

        [] ->
            Nothing


{-| Get the minimum and maximum X, Y and Z values of a bounding box in a single
record.

    BoundingBox3d.extrema exampleBox
    --> { minX = -2
    --> , maxX = 2
    --> , minY = 2
    --> , maxY = 5
    --> , minZ = 3
    --> , maxZ = 4
    --> }

Can be useful when combined with record destructuring, for example

    { minX, maxX, minY, maxY, minZ, maxZ } =
        BoundingBox3d.extrema exampleBox


    --> minX = -2
    --> maxX = 2
    --> minY = 2
    --> maxY = 5
    --> minZ = 3
    --> maxZ = 4

-}
extrema : BoundingBox3d -> { minX : Float, maxX : Float, minY : Float, maxY : Float, minZ : Float, maxZ : Float }
extrema (Internal.BoundingBox3d properties) =
    properties


{-| Get the minimum X value of a bounding box.

    BoundingBox3d.minX exampleBox
    --> -2

-}
minX : BoundingBox3d -> Float
minX boundingBox =
    (extrema boundingBox).minX


{-| Get the maximum X value of a bounding box.

    BoundingBox3d.maxX exampleBox
    --> 2

-}
maxX : BoundingBox3d -> Float
maxX boundingBox =
    (extrema boundingBox).maxX


{-| Get the minimum Y value of a bounding box.

    BoundingBox3d.minY exampleBox
    --> 2

-}
minY : BoundingBox3d -> Float
minY boundingBox =
    (extrema boundingBox).minY


{-| Get the maximum Y value of a bounding box.

    BoundingBox3d.maxY exampleBox
    --> 5

-}
maxY : BoundingBox3d -> Float
maxY boundingBox =
    (extrema boundingBox).maxY


{-| Get the minimum Z value of a bounding box.

    BoundingBox3d.minZ exampleBox
    --> 3

-}
minZ : BoundingBox3d -> Float
minZ boundingBox =
    (extrema boundingBox).minZ


{-| Get the maximum Z value of a bounding box.

    BoundingBox3d.maxZ exampleBox
    --> 4

-}
maxZ : BoundingBox3d -> Float
maxZ boundingBox =
    (extrema boundingBox).maxZ


{-| Get the X, Y and Z dimensions (widths) of a bounding box.

    BoundingBox3d.dimensions exampleBox
    --> ( 4, 3, 1 )

-}
dimensions : BoundingBox3d -> ( Float, Float, Float )
dimensions boundingBox =
    let
        { minX, maxX, minY, maxY, minZ, maxZ } =
            extrema boundingBox
    in
    ( maxX - minX, maxY - minY, maxZ - minZ )


{-| Get the median X value of a bounding box.

    BoundingBox3d.midX exampleBox
    --> 0

-}
midX : BoundingBox3d -> Float
midX boundingBox =
    let
        { minX, maxX } =
            extrema boundingBox
    in
    minX + 0.5 * (maxX - minX)


{-| Get the median Y value of a bounding box.

    BoundingBox3d.midY exampleBox
    --> 3.5

-}
midY : BoundingBox3d -> Float
midY boundingBox =
    let
        { minY, maxY } =
            extrema boundingBox
    in
    minY + 0.5 * (maxY - minY)


{-| Get the median Z value of a bounding box.

    BoundingBox3d.midZ exampleBox
    --> 3.5

-}
midZ : BoundingBox3d -> Float
midZ boundingBox =
    let
        { minZ, maxZ } =
            extrema boundingBox
    in
    minZ + 0.5 * (maxZ - minZ)


{-| Get the point at the center of a bounding box.

    BoundingBox3d.centroid exampleBox
    --> Point3d.fromCoordinates ( 0, 3.5, 3.5 )

-}
centroid : BoundingBox3d -> Point3d
centroid boundingBox =
    Point3d.fromCoordinates
        ( midX boundingBox
        , midY boundingBox
        , midZ boundingBox
        )


{-| Check if a bounding box contains a particular point.

    firstPoint =
        Point3d.fromCoordinates ( 1, 4, 3 )

    secondPoint =
        Point3d.fromCoordinates ( 3, 4, 5 )

    BoundingBox3d.contains firstPoint exampleBox
    --> True

    BoundingBox3d.contains secondPoint exampleBox
    --> False

-}
contains : Point3d -> BoundingBox3d -> Bool
contains point boundingBox =
    let
        ( x, y, z ) =
            Point3d.coordinates point

        { minX, maxX, minY, maxY, minZ, maxZ } =
            extrema boundingBox
    in
    (minX <= x && x <= maxX)
        && (minY <= y && y <= maxY)
        && (minZ <= z && z <= maxZ)


{-| Test if one bounding box overlaps (touches) another.

    firstBox =
        BoundingBox3d.with
            { minX = 0
            , maxX = 3
            , minY = 0
            , maxY = 2
            , minZ = 0
            , maxZ = 1
            }

    secondBox =
        BoundingBox3d.with
            { minX = 0
            , maxX = 3
            , minY = 1
            , maxY = 4
            , minZ = -1
            , maxZ = 2
            }

    thirdBox =
        BoundingBox3d.with
            { minX = 0
            , maxX = 3
            , minY = 4
            , maxY = 5
            , minZ = -1
            , maxZ = 2
            }

    BoundingBox3d.overlaps firstBox secondBox
    --> True

    BoundingBox3d.overlaps firstBox thirdBox
    --> False

-}
overlaps : BoundingBox3d -> BoundingBox3d -> Bool
overlaps other boundingBox =
    (minX boundingBox <= maxX other)
        && (maxX boundingBox >= minX other)
        && (minY boundingBox <= maxY other)
        && (maxY boundingBox >= minY other)
        && (minZ boundingBox <= maxZ other)
        && (maxZ boundingBox >= minZ other)


{-| Test if the second given bounding box is fully contained within the first
(is a subset of it).

    outerBox =
        BoundingBox3d.with
            { minX = 0
            , maxX = 10
            , minY = 0
            , maxY = 10
            , minZ = 0
            , maxZ = 10
            }

    innerBox =
        BoundingBox3d.with
            { minX = 1
            , maxX = 5
            , minY = 3
            , maxY = 9
            , minZ = 7
            , maxZ = 8
            }

    overlappingBox =
        BoundingBox3d.with
            { minX = 1
            , maxX = 5
            , minY = 3
            , maxY = 12
            , minZ = 7
            , maxZ = 8
            }

    BoundingBox3d.isContainedIn outerBox innerBox
    --> True

    BoundingBox3d.isContainedIn outerBox overlappingBox
    --> False

-}
isContainedIn : BoundingBox3d -> BoundingBox3d -> Bool
isContainedIn other boundingBox =
    (minX other <= minX boundingBox && maxX boundingBox <= maxX other)
        && (minY other <= minY boundingBox && maxY boundingBox <= maxY other)
        && (minZ other <= minZ boundingBox && maxZ boundingBox <= maxZ other)


{-| Build a bounding box that contains both given bounding boxes.

    firstBox =
        BoundingBox3d.with
            { minX = 1
            , maxX = 4
            , minY = 2
            , maxY = 3
            , minZ = 0
            , maxZ = 5
            }

    secondBox =
        BoundingBox3d.with
            { minX = -2
            , maxX = 2
            , minY = 4
            , maxY = 5
            , minZ = -1
            , maxZ = 0
            }

    BoundingBox3d.hull firstBox secondBox
    --> BoundingBox3d.with
    -->     { minX = -2
    -->     , maxX = 4
    -->     , minY = 2
    -->     , maxY = 5
    -->     , minZ = -1
    -->     , maxZ = 5
    -->     }

-}
hull : BoundingBox3d -> BoundingBox3d -> BoundingBox3d
hull firstBox secondBox =
    with
        { minX = min (minX firstBox) (minX secondBox)
        , maxX = max (maxX firstBox) (maxX secondBox)
        , minY = min (minY firstBox) (minY secondBox)
        , maxY = max (maxY firstBox) (maxY secondBox)
        , minZ = min (minZ firstBox) (minZ secondBox)
        , maxZ = max (maxZ firstBox) (maxZ secondBox)
        }


{-| Attempt to build a bounding box that contains all points common to both
given bounding boxes. If the given boxes do not overlap, returns `Nothing`.

    firstBox =
        BoundingBox3d.with
            { minX = 1
            , maxX = 4
            , minY = 2
            , maxY = 3
            , minZ = 5
            , maxZ = 8
            }

    secondBox =
        BoundingBox3d.with
            { minX = 2
            , maxX = 5
            , minY = 1
            , maxY = 4
            , minZ = 6
            , maxZ = 7
            }

    thirdBox =
        BoundingBox3d.with
            { minX = 1
            , maxX = 4
            , minY = 4
            , maxY = 5
            , minZ = 5
            , maxZ = 8
            }

    BoundingBox3d.intersection firstBox secondBox
    --> Just
    -->     (BoundingBox3d.with
    -->         { minX = 2
    -->         , maxX = 4
    -->         , minY = 2
    -->         , maxY = 3
    -->         , minZ = 6
    -->         , maxZ = 7
    -->         }
    -->     )

    BoundingBox3d.intersection firstBox thirdBox
    --> Nothing

-}
intersection : BoundingBox3d -> BoundingBox3d -> Maybe BoundingBox3d
intersection firstBox secondBox =
    if overlaps firstBox secondBox then
        Just
            (with
                { minX = max (minX firstBox) (minX secondBox)
                , maxX = min (maxX firstBox) (maxX secondBox)
                , minY = max (minY firstBox) (minY secondBox)
                , maxY = min (maxY firstBox) (maxY secondBox)
                , minZ = max (minZ firstBox) (minZ secondBox)
                , maxZ = min (maxZ firstBox) (maxZ secondBox)
                }
            )
    else
        Nothing
