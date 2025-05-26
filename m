import pygame
import random

pygame.init()

WIDTH, HEIGHT = 600, 400
CIRCLE_RADIUS = 20
SQUARE_SIZE = 30
BASE_SPEED = 5
POWERUP_DURATION = 5000  # milliseconds

WHITE = (255, 255, 255)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
YELLOW = (255, 255, 0)
GREEN = (0, 255, 0)
BLACK = (0, 0, 0)

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Catch the Square Enhanced")
clock = pygame.time.Clock()

# Sounds
catch_sound = pygame.mixer.Sound(pygame.mixer.Sound(pygame.mixer.get_init() and pygame.mixer.get_init() or ""))
hit_sound = pygame.mixer.Sound(pygame.mixer.Sound(pygame.mixer.get_init() and pygame.mixer.get_init() or ""))
powerup_sound = pygame.mixer.Sound(pygame.mixer.Sound(pygame.mixer.get_init() and pygame.mixer.get_init() or ""))

class Circle:
    def __init__(self):
        self.x = WIDTH // 2
        self.y = HEIGHT // 2
        self.speed = BASE_SPEED

    def move(self, keys):
        if keys[pygame.K_UP] and self.y - CIRCLE_RADIUS > 0:
            self.y -= self.speed
        if keys[pygame.K_DOWN] and self.y + CIRCLE_RADIUS < HEIGHT:
            self.y += self.speed
        if keys[pygame.K_LEFT] and self.x - CIRCLE_RADIUS > 0:
            self.x -= self.speed
        if keys[pygame.K_RIGHT] and self.x + CIRCLE_RADIUS < WIDTH:
            self.x += self.speed

    def draw(self):
        pygame.draw.circle(screen, BLUE, (self.x, self.y), CIRCLE_RADIUS)

class Square:
    def __init__(self):
        self.reset_position()

    def reset_position(self):
        self.x = random.randint(0, WIDTH - SQUARE_SIZE)
        self.y = random.randint(0, HEIGHT - SQUARE_SIZE)

    def draw(self):
        pygame.draw.rect(screen, RED, (self.x, self.y, SQUARE_SIZE, SQUARE_SIZE))

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
        self.type = random.choice(['speed', 'multiplier'])
        self.radius = 15

    def draw(self):
        color = YELLOW if self.type == 'speed' else (255, 0, 255)  # Yellow for speed, Magenta for multiplier
        pygame.draw.circle(screen, color, (self.x, self.y), self.radius)

    def check_collision(self, circle_x, circle_y):
        return abs(circle_x - self.x) < CIRCLE_RADIUS + self.radius and abs(circle_y - self.y) < CIRCLE_RADIUS + self.radius

class Timer:
    def __init__(self, duration):
        self.duration = duration
        self.start_time = pygame.time.get_ticks()

    def time_left(self):
        return max(0, self.duration - (pygame.time.get_ticks() - self.start_time))

    def reset(self):
        self.start_time = pygame.time.get_ticks()

    def draw(self, font, pos):
        time_left = self.time_left() // 1000
        timer_text = font.render(f"{time_left}s", True, BLACK)
        screen.blit(timer_text, pos)

def dynamic_background(elapsed):
    r = int((1 + pygame.math.sin(elapsed * 0.002)) * 127)
    g = int((1 + pygame.math.sin(elapsed * 0.003 + 2)) * 127)
    b = int((1 + pygame.math.sin(elapsed * 0.004 + 4)) * 127)
    return (r, g, b)

def game_over_screen(score, font):
    screen.fill(WHITE)
    go_text = font.render("Game Over!", True, RED)
    score_text = font.render(f"Final Score: {score}", True, BLACK)
    restart_text = font.render("Press R to Restart or Q to Quit", True, BLACK)
    screen.blit(go_text, (WIDTH // 2 - go_text.get_width() // 2, HEIGHT // 3))
    screen.blit(score_text, (WIDTH // 2 - score_text.get_width() // 2, HEIGHT // 3 + 50))
    screen.blit(restart_text, (WIDTH // 2 - restart_text.get_width() // 2, HEIGHT // 3 + 100))
    pygame.display.update()

def game_loop():
    circle = Circle()
    square = Square()
    obstacles = [Obstacle() for _ in range(3)]
    powerups = [PowerUp() for _ in range(2)]
    timer = Timer(30000)
    speed_powerup_timer = None
    multiplier_powerup_timer = None
    score = 0
    score_multiplier = 1
    font = pygame.font.Font(None, 36)
    running = True
    paused = False

    while running:
        elapsed = pygame.time.get_ticks()
        screen.fill(dynamic_background(elapsed))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                    paused = not paused
                if event.key == pygame.K_r and not running:
                    game_loop()  # Restart game
                    return
                if event.key == pygame.K_q and not running:
                    return

        if paused:
            pause_text = font.render("Paused - Press P to Resume", True, BLACK)
            screen.blit(pause_text, (WIDTH//2 - pause_text.get_width()//2, HEIGHT//2))
            pygame.display.update()
            clock.tick(30)
            continue

        keys = pygame.key.get_pressed()
        circle.move(keys)

        circle.draw()
        square.draw()
        for obs in obstacles:
            obs.draw()
        for pu in powerups:
            pu.draw()

        if abs(circle.x - square.x) < CIRCLE_RADIUS + SQUARE_SIZE // 2 and abs(circle.y - square.y) < CIRCLE_RADIUS + SQUARE_SIZE // 2:
            score += score_multiplier
            square.reset_position()
            pygame.mixer.Sound.play(catch_sound)

        for obs in obstacles:
            if obs.check_collision(circle.x, circle.y):
                score = max(0, score - 1)
                pygame.mixer.Sound.play(hit_sound)

        for i, pu in enumerate(powerups):
            if pu.check_collision(circle.x, circle.y):
                if pu.type == 'speed':
                    circle.speed = BASE_SPEED + 3
                    speed_powerup_timer = Timer(POWERUP_DURATION)
                else:
                    score_multiplier = 2
                    multiplier_powerup_timer = Timer(POWERUP_DURATION)
                powerups[i] = PowerUp()
                pygame.mixer.Sound.play(powerup_sound)

        if speed_powerup_timer and speed_powerup_timer.time_left() == 0:
            circle.speed = BASE_SPEED
            speed_powerup_timer = None

        if multiplier_powerup_timer and multiplier_powerup_timer.time_left() == 0:
            score_multiplier = 1
            multiplier_powerup_timer = None

        timer.draw(font, (WIDTH - 80, 10))

        if timer.time_left() == 0:
            running = False

        score_text = font.render(f"Score: {score}", True, BLACK)
        screen.blit(score_text, (10, 10))

        pygame.display.update()
        clock.tick(30)

    # Game Over Screen
    game_over_screen(score, font)

    # Wait for restart or quit
    waiting = True
    while waiting:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                waiting = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_r:
                    game_loop()
                    return
                if event.key == pygame.K_q:
                    waiting = False
        clock.tick(15)

game_loop()
pygame.quit()
