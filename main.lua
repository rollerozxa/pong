
require('util')

speed = 8

resolution = {
	x = 800,
	y = 600
}
paddle = Obj(16, 64, 16, 128)
enemyPaddle = Obj(768, 64, 16, 128)

ball = Obj(400, 300, 16, 16)
ball.vel = {
	x = speed,
	y = speed
}

score = {
	player = 0,
	enemy = 0
}

function BallReset(winner)
	if winner == 'player' then
		score.player = score.player + 1
	else
		score.enemy = score.enemy + 1
	end

	sounds.score:play()
	ball.x = 400
	ball.y = 300

	if winner == 'player' then
		ball.vel.x = speed
	else
		ball.vel.x = -speed
	end

	if math.random(2) == 2 then
		ball.vel.y = speed
	else
		ball.vel.y = -speed
	end
end

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest', 4)

	fonts = {
		default = love.graphics.newFont(11),
		number = love.graphics.newImageFont("assets/numberfont.png", "0123456789")
	}
	sounds = {
		paddle = love.audio.newSource("sounds/paddle.wav", "static"),
		score = love.audio.newSource("sounds/score.wav", "static"),
		wall = love.audio.newSource("sounds/wall.wav", "static")
	}

	love.graphics.setFont(fonts.default)
end

function love.update()
	paddle.y = math.clamp(16, love.mouse.getY() - 64, 455)

	--enemyPaddle.y = math.clamp(16, ball.y - 64, 455)
	enemyPaddle.y = math.clamp(16, math.lerp(enemyPaddle.y, ball.y - 64, 0.09), 455)

	-- Up & Bottom collision check
	if CheckCollisionObj(ball, Obj(0, -32 + 8, resolution.x, 32))
	or CheckCollisionObj(ball, Obj(0, resolution.y - 16, resolution.x, 32)) then
		sounds.wall:play()
		ball.vel.y = -ball.vel.y
	end

	-- Paddle collision check
	if CheckCollisionObj(ball, paddle)
	or CheckCollisionObj(ball, enemyPaddle) then
		sounds.paddle:play()
		ball.vel.x = -ball.vel.x
	end

	if CheckCollisionObj(ball, Obj(-32, 0, 32, resolution.y)) then
		BallReset('enemy')
	end

	if CheckCollisionObj(ball, Obj(resolution.x, 0, 32, resolution.y)) then
		BallReset('player')
	end

	ball.x = ball.x + ball.vel.x
	ball.y = ball.y + ball.vel.y
end

function love.draw()
	love.graphics.setBackgroundColor(0,0,0)

	love.graphics.setColor(1,1,1)

	love.graphics.rectangle('fill', paddle.x, paddle.y, paddle.size.x, paddle.size.y)

	love.graphics.rectangle('fill', enemyPaddle.x, enemyPaddle.y, 16, 128)

	local i = 0
	local drawing = true
	while drawing do
		if i * 32 > resolution.y then
			drawing = false
		else
			love.graphics.rectangle('fill', (resolution.x / 2) - 4, (i * 32) +8, 8, 16)
			i = i + 1
		end
	end

	love.graphics.rectangle('fill', 0, 0, resolution.x, 8)
	love.graphics.rectangle('fill', 0, resolution.y -8, resolution.x, 8)

	love.graphics.setFont(fonts.number)
	love.graphics.print(score.player, (resolution.x / 2) - 76, 20, 0, 10, 10)
	love.graphics.print(score.enemy, (resolution.x / 2) + 32, 20, 0, 10, 10)

	love.graphics.rectangle('fill', ball.x, ball.y, ball.size.x, ball.size.y)

	love.graphics.setFont(fonts.default)
	love.graphics.print("FPS: "..love.timer.getFPS()..", paddle = { x = "..paddle.x..", y = "..paddle.y.." }", 5, 10)
end