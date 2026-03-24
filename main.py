import turtle
import time
import random

# --- Game Configuration ---
delay = 0.1
score = 0
high_score = 0
game_state = "menu"  # States: 'menu', 'playing', 'game_over'

# Set up the screen
wn = turtle.Screen()
wn.title("Classic Snake")
wn.bgcolor("black")
wn.setup(width=600, height=600)
wn.tracer(0) # Turns off automatic screen updates for smoother animations

# --- Game Objects ---

# Snake head
head = turtle.Turtle()
head.speed(0)
head.shape("square")
head.color("green")
head.penup()
head.goto(0, 0)
head.direction = "stop"

# Standard Snake food
food = turtle.Turtle()
food.speed(0)
food.shape("circle")
food.color("red")
food.penup()
food.goto(0, 100)

# Golden Bonus Food
bonus_food = turtle.Turtle()
bonus_food.speed(0)
bonus_food.shape("triangle")
bonus_food.color("gold")
bonus_food.penup()
bonus_food.goto(1000, 1000) # Hide off-screen initially
bonus_active = False
bonus_timer = 0

# List to store the snake's body parts
segments = []

# List to store obstacles
obstacles = []

# Pen (for the scoreboard and text)
pen = turtle.Turtle()
pen.speed(0)
pen.shape("square")
pen.color("white")
pen.penup()
pen.hideturtle()

# Border Pen
border_pen = turtle.Turtle()
border_pen.speed(0)
border_pen.color("gray")
border_pen.penup()
border_pen.hideturtle()

# --- Functions ---

def draw_border():
    """Draws a visible border for the play area."""
    border_pen.clear()
    border_pen.goto(-290, -290)
    border_pen.pendown()
    border_pen.pensize(3)
    for _ in range(4):
        border_pen.forward(580)
        border_pen.left(90)
    border_pen.penup()

def create_obstacle(x, y):
    """Creates a wall obstacle at the given coordinates."""
    obs = turtle.Turtle()
    obs.speed(0)
    obs.shape("square")
    obs.color("gray")
    obs.penup()
    obs.goto(x, y)
    obstacles.append(obs)

def setup_level():
    """Sets up obstacles for the level."""
    for obs in obstacles:
        obs.goto(1000, 1000)
    obstacles.clear()
    
    # Create a few random obstacles on the grid
    for _ in range(5):
        x = random.randint(-12, 12) * 20
        y = random.randint(-12, 12) * 20
        # Prevent obstacles from spawning on the snake or food
        if (x, y) != (0, 0) and (x, y) != (food.xcor(), food.ycor()):
            create_obstacle(x, y)

def show_menu():
    """Displays the main menu."""
    pen.clear()
    pen.goto(0, 50)
    pen.write("CLASSIC SNAKE", align="center", font=("Courier", 36, "bold"))
    pen.goto(0, -20)
    pen.write("Press SPACE to Start", align="center", font=("Courier", 18, "normal"))
    pen.goto(0, -60)
    pen.write("Use WASD or Arrow Keys to move", align="center", font=("Courier", 14, "normal"))

def show_game_over():
    """Displays the game over screen."""
    pen.clear()
    pen.goto(0, 50)
    pen.write("GAME OVER", align="center", font=("Courier", 36, "bold"))
    pen.goto(0, 0)
    pen.write(f"Final Score: {score}", align="center", font=("Courier", 24, "normal"))
    pen.goto(0, -40)
    pen.write("Press SPACE to Restart", align="center", font=("Courier", 18, "normal"))

def update_score():
    """Updates the scoreboard at the top."""
    pen.clear()
    pen.goto(0, 260)
    pen.write("Score: {}  High Score: {}".format(score, high_score), align="center", font=("Courier", 24, "normal"))

def start_game():
    """Transitions from menu/game over to active gameplay."""
    global game_state, score, delay, bonus_active
    if game_state != "playing":
        game_state = "playing"
        score = 0
        delay = 0.1
        bonus_active = False
        bonus_food.goto(1000, 1000)
        
        # Reset Snake
        head.goto(0, 0)
        head.direction = "stop"
        
        # Hide the body segments off-screen
        for segment in segments:
            segment.goto(1000, 1000)
        segments.clear()
        
        # Reset Food
        move_food(food)
        
        # Setup level details
        draw_border()
        setup_level()
        update_score()

def move_food(food_item):
    """Moves food to a random grid location, avoiding obstacles."""
    while True:
        x = random.randint(-14, 14) * 20
        y = random.randint(-14, 14) * 20
        
        # Check if new location collides with an obstacle
        collision = False
        for obs in obstacles:
            if obs.distance(x, y) < 20:
                collision = True
                break
        
        if not collision:
            food_item.goto(x, y)
            break

# Movement Functions
def go_up():
    if head.direction != "down" and game_state == "playing":
        head.direction = "up"

def go_down():
    if head.direction != "up" and game_state == "playing":
        head.direction = "down"

def go_left():
    if head.direction != "right" and game_state == "playing":
        head.direction = "left"

def go_right():
    if head.direction != "left" and game_state == "playing":
        head.direction = "right"

def move():
    if head.direction == "up":
        head.sety(head.ycor() + 20)
    if head.direction == "down":
        head.sety(head.ycor() - 20)
    if head.direction == "left":
        head.setx(head.xcor() - 20)
    if head.direction == "right":
        head.setx(head.xcor() + 20)

def trigger_game_over():
    """Handles the logic for dying."""
    global game_state, high_score
    game_state = "game_over"
    if score > high_score:
        high_score = score
    time.sleep(1)
    border_pen.clear()
    for obs in obstacles:
        obs.goto(1000, 1000)
    obstacles.clear()
    head.goto(1000, 1000)
    food.goto(1000, 1000)
    bonus_food.goto(1000, 1000)
    for segment in segments:
        segment.goto(1000, 1000)
    show_game_over()

# --- Keyboard Bindings ---
wn.listen()
wn.onkeypress(start_game, "space")
wn.onkeypress(go_up, "w")
wn.onkeypress(go_down, "s")
wn.onkeypress(go_left, "a")
wn.onkeypress(go_right, "d")
wn.onkeypress(go_up, "Up")
wn.onkeypress(go_down, "Down")
wn.onkeypress(go_left, "Left")
wn.onkeypress(go_right, "Right")

# --- Initialization ---
show_menu()

# --- Main Game Loop ---
while True:
    wn.update() # Update the screen

    if game_state == "playing":
        
        # 1. Check for collision with the border
        if head.xcor() > 280 or head.xcor() < -280 or head.ycor() > 280 or head.ycor() < -280:
            trigger_game_over()
            continue

        # 2. Check for collision with obstacles
        for obs in obstacles:
            if head.distance(obs) < 20:
                trigger_game_over()
                continue

        # 3. Check for collision with normal food
        if head.distance(food) < 20:
            move_food(food)

            # Add a new segment
            new_segment = turtle.Turtle()
            new_segment.speed(0)
            new_segment.shape("square")
            new_segment.color("light green")
            new_segment.penup()
            segments.append(new_segment)

            delay = max(0.04, delay - 0.002) # Speed up, but set a limit
            score += 10
            
            # Chance to spawn bonus food
            if not bonus_active and random.randint(1, 5) == 1:
                bonus_active = True
                bonus_timer = 50 # Lasts for 50 frames
                move_food(bonus_food)

            update_score()

        # 4. Check for collision with bonus food
        if bonus_active:
            bonus_timer -= 1
            if head.distance(bonus_food) < 20:
                score += 50
                bonus_active = False
                bonus_food.goto(1000, 1000)
                update_score()
            elif bonus_timer <= 0:
                bonus_active = False
                bonus_food.goto(1000, 1000) # Disappear if time runs out

        # 5. Move the end segments first in reverse order
        for index in range(len(segments)-1, 0, -1):
            x = segments[index-1].xcor()
            y = segments[index-1].ycor()
            segments[index].goto(x, y)

        # 6. Move segment 0 (the neck) to where the head is
        if len(segments) > 0:
            x = head.xcor()
            y = head.ycor()
            segments[0].goto(x, y)

        # 7. Move the head
        move()    

        # 8. Check for head collision with the body segments
        for segment in segments:
            if segment.distance(head) < 20:
                trigger_game_over()

        time.sleep(delay)

wn.mainloop()
