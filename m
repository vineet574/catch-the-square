import pygame
import random

# Initialize Pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 600, 400
CIRCLE_RADIUS = 20
SQUARE_SIZE = 30
SPEED = 5
TIMER_DURATION = 30000  # 30 seconds

WHITE = (255, 255, 255)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
YELLOW = (255, 255, 0)
GREEN = (0, 255, 0)

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Catch the Square")
clock = pygame.time.Clock()

# Classes
class Circle:
    def __init__(self):
        self.x = WIDTH // 2
        self.y = HEIGHT // 2

    def move(self, keys):
        if keys[pygame.K_UP] and self.y - CIRCLE_RADIUS > 0:
            self.y -= SPEED
        if keys[pygame.K_DOWN] and self.y + CIRCLE_RADIUS < HEIGHT:
            self.y += SPEED
        if keys[pygame.K_LEFT] and self.x - CIRCLE_RADIUS > 0:
            self.x -= SPEED
        if keys[pygame.K_RIGHT] and self.x + CIRCLE_RADIUS < WIDTH:
            self.x += SPEED

    def draw(self):
        pygame.draw.circle(screen, BLUE, (self.x, self.y), CIRCLE_RADIUS)

class Square:
    def __init__(self):
        self.x = random.randint(0, WIDTH - SQUARE_SIZE)
        self.y = random.randint(0, HEIGHT - SQUARE_SIZE)

    def draw(self):
        pygame.draw.rect(screen, RED, (self.x, self.y, SQUARE_SIZE, SQUARE_SIZE))

    def reset_position(self):
        self.x = random.randint(0, WIDTH - SQUARE_SIZE)
        self.y = random.randint(0, HEIGHT - SQUARE_SIZE)

class Obstacle:
    def __init__(self):
        self.x = random.randint(0, WIDTH - SQUARE_SIZE)
        self.y = random.randint(0, HEIGHT - SQUARE_SIZE)

    def draw(self):
        pygame.draw.rect(screen, GREEN, (self.x, self.y, SQUARE_SIZE, SQUARE_SIZE))

    def check_collision(self, circle_x, circle_y):
        return abs(circle_x - self.x) < CIRCLE_RADIUS + SQUARE_SIZE // 2 and abs(circle_y - self.y) < CIRCLE_RADIUS + SQUARE_SIZE // 2

class PowerUp:
    def __init__(self):
        self.x = random.randint(0, WIDTH - SQUARE_SIZE)
        self.y = random.randint(0, HEIGHT - SQUARE_SIZE)

    def draw(self):
        pygame.draw.circle(screen, YELLOW, (self.x, self.y), 15)

    def check_collision(self, circle_x, circle_y):
        return abs(circle_x - self.x) < CIRCLE_RADIUS + 15

    def activate(self):
        global SPEED
        SPEED += 2

class Timer:
    def __init__(self):
        self.start_time = pygame.time.get_ticks()

    def time_left(self):
        return max(0, TIMER_DURATION - (pygame.time.get_ticks() - self.start_time))

    def draw(self, font):
        time_left = self.time_left() // 1000
        timer_text = font.render(f"Time: {time_left}s", True, (0, 0, 0))
        screen.blit(timer_text, (WIDTH - 120, 10))

# Dynamic Background
def dynamic_background(score):
    r = min(255, score * 20)
    g = max(0, 255 - score * 15)
    b = 200
    return (r, g, b)

# Game Loop
def game_loop():
    circle = Circle()
    square = Square()
    obstacle = Obstacle()
    power_up = PowerUp()
    timer = Timer()
    score = 0
    font = pygame.font.Font(None, 36)
    running = True

    while running:
        screen.fill(dynamic_background(score))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        keys = pygame.key.get_pressed()
        circle.move(keys)

        circle.draw()
        square.draw()
        obstacle.draw()
        power_up.draw()

        # Collision with Square
        if abs(circle.x - square.x) < CIRCLE_RADIUS + SQUARE_SIZE // 2 and abs(circle.y - square.y) < CIRCLE_RADIUS + SQUARE_SIZE // 2:
            score += 1
            square.reset_position()

        # Collision with Obstacle
        if obstacle.check_collision(circle.x, circle.y):
            score = max(0, score - 1)

        # Collision with Power-up
        if power_up.check_collision(circle.x, circle.y):
            power_up.activate()
            power_up = PowerUp()  # Reset power-up

        # Timer
        timer.draw(font)
        if timer.time_left() == 0:
            running = False

        # Score
        score_text = font.render(f"Score: {score}", True, (0, 0, 0))
        screen.blit(score_text, (10, 10))

        pygame.display.update()
        clock.tick(30)

game_loop()
pygame.quit()
