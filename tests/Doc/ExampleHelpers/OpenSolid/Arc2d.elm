module Doc.ExampleHelpers.OpenSolid.Arc2d exposing (..)

{- This file contains the variables used in the examples in tests/Arc2d.elm -}

import OpenSolid.Arc2d as Arc2d
import OpenSolid.Axis2d as Axis2d
import OpenSolid.Direction2d as Direction2d
import OpenSolid.Frame2d as Frame2d
import OpenSolid.LineSegment2d as LineSegment2d
import OpenSolid.Point2d as Point2d
import OpenSolid.Polyline2d as Polyline2d
import OpenSolid.Vector2d as Vector2d


exampleArc =
    Arc2d.with
        { centerPoint =
            Point2d.fromCoordinates ( 1, 1 )
        , startPoint =
            Point2d.fromCoordinates ( 3, 1 )
        , sweptAngle = degrees 90
        }


p1 =
    Point2d.fromCoordinates ( 1, 0 )


p2 =
    Point2d.fromCoordinates ( 0, 1 )


point =
    Point2d.fromCoordinates ( 0, 1 )


displacement =
    Vector2d.fromComponents ( 2, 3 )


localFrame =
    Frame2d.atPoint (Point2d.fromCoordinates ( 1, 2 ))
