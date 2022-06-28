import QtQuick 2.0
import Felgo 3.0

EntityBase {
    id: plane
    // the enityId should be set by the level file!
    entityType: "plane"

    property alias inputActionsToKeyCode: twoAxisController.inputActionsToKeyCode
    property alias image: image

    // gets accessed to insert the input when touching the HUDController
    property alias controller: twoAxisController

    readonly property real forwardForce: 1000 * world.pixelsPerMeter

    Component.onCompleted: {
        console.debug("planeEnemy.onCompleted()")
        console.debug("planeEnemy.x:", x)
        var mapped = mapToItem(world.debugDraw, x, y)
        console.debug("planeEnemy.x world:", mapped.x)

        x = utils.generateRandomValueBetween(0,scene.width)
        y = 0;
    }

    Image {
        id: image
        source: "../../assets/img/img-plane_3.png"

        anchors.centerIn: parent
        width: boxCollider.width
        height: boxCollider.height

        MovementAnimation {
            target: plane
            property: "y"
            running: true

            // the starting velocity
            velocity: 10

//            // this forces the rectangle to move to the left (against the velocity direction), but it doesnt get faster than -20 px/second!
            acceleration: 40

            minVelocity: -200
            // limits the initial velocity set to 960, now to 500
            maxVelocity: 500

            // limits the x property between a border of 10 and 100
            //            minPropertyValue: 10
            //            maxPropertyValue: 1000

            // never change the x value by more than 50 pixels in one step
            // this is useful for example to limit the rotation from MoveToPointHelper
            maxPropertyValueDifference: 50

        }

    }

    // this is used as input for the BoxCollider force & torque properties
    TwoAxisController {
        id: twoAxisController

        // call the logic function when an input press (possibly the fire event) is received
        onInputActionPressed: handleInputAction(actionName)
    }

    BoxCollider {
        id: boxCollider

        // the image and the physics will use this size; this is important as it specifies the mass of the body! it is in respect to the world size
        width: 90
        height: 85

        anchors.centerIn: parent

        density: 0.008
        friction: 0.5
        restitution: 0.5
        body.bullet: true
        body.linearDamping: 5
        body.angularDamping: 15

        // do not change rotation
        body.fixedRotation: true

        // this is applied every physics update tick
        force: Qt.point(twoAxisController.yAxis*forwardForce, twoAxisController.xAxis*forwardForce)

        Component.onCompleted: {
            console.debug("planeEnemy.physics.x:", x)
            var mapped = mapToItem(world.debugDraw, x, y)
            console.debug("planeEnemy.physics.x world:", mapped.x)
        }

        property int boomflag: 0
        fixture.onBeginContact: {
            var fixture = other
            var body = other.getBody()
            var component = other.getBody().target
            var collidingType = component.entityType

            if(collidingType === "plane" || collidingType === "bullet") {
                boomflag++;
                if(boomflag === 3){
                    plane.removeEntity();
                    boomflag = 0;
                }
                return
            }
            if(collidingType === "wall") {
                plane.removeEntity();
                return
            }
            //var
            console.debug("planeEnemy contact with: ", other, body, component)
            console.debug("planeEnemy collided entity type:", collidingType)

            console.debug("planeEnemy contactNormal:", contactNormal, "x:", contactNormal.x, "y:", contactNormal.y)

        }
    }
    Timer {
        id: bulletshoot
        interval: 2000 // milliseconds
        repeat: true
        running: true
        triggeredOnStart: false
        onTriggered: {

//            plane.autoFire();
            // if the maximum number of balloons is reached, we stop the timer and therefore the balloon creation
            console.log("shoot");
        }
    }
//    function autoFire() {
//        // create the bullet at the specified position with the rotation of the plane that fires it
//        entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Bullet.qml"), {"x": plane_enemy1.x, "y": plane_enemy1.y, "rotation": plane_enemy1.rotation + 90, "visible" : true})
//    }
}
