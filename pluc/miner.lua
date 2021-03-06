os.loadAPI("/gitlib/turboCo/dashboard.lua")

function dropAllButOne(slot)
    turtle.select(slot)
    turtle.drop(turtle.getItemCount() - 1)
end

function force()
    while turtle.inspect() do
        turtle.dig()
    end
    turtle.forward()
end

function forceUp()
    while turtle.inspectUp() do
        turtle.digUp()
    end
    turtle.up()
end

function forceDown()
    while turtle.inspectDown() do
        turtle.digDown()
    end
    turtle.down()
end

function cleanup()
    dropAllButOne(2)
    dropAllButOne(3)
    dropAllButOne(4)
    dropAllButOne(5)
    dropAllButOne(6)
    dropAllButOne(7)
    turtle.select(1)
end

for i = 0, 100 do
    turtle.refuel(2)
    cleanup()
    for y = 0, 50 do
        force()
        if y % 10 == 0 then
            dashboard.updateRobot()
        end
    end
    forceUp()
    turtle.turnLeft()
    turtle.turnLeft()
    cleanup()
    for y = 0, 50 do
        force()
        if y % 10 == 0 then
            dashboard.updateRobot()
        end
    end
    forceDown()
    turtle.turnRight()
    force()
    turtle.turnRight()
end
