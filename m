import pygame
import random

pygame.init()

WIDTH, HEIGHT = 600, 400
CIRCLE_RADIUS = 20
SQUARE_SIZE = 30
SPEED = 5

WHITE = (255, 255, 255)
RED = (255, 0, 0)
BLUE = (0, 0, 255)

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Catch the Square")

clock = pygame.time.Clock()

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

def game_loop():
    circle = Circle()
    square = Square()
    score = 0
    font = pygame.font.Font(None, 36)
    running = True

    while running:
        screen.fill(WHITE)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        keys = pygame.key.get_pressed()
        circle.move(keys)

        circle.draw()
        square.draw()

        if abs(circle.x - square.x) < CIRCLE_RADIUS + SQUARE_SIZE // 2 and abs(circle.y - square.y) < CIRCLE_RADIUS + SQUARE_SIZE // 2:
            score += 1
            square.reset_position()

        score_text = font.render(f"Score: {score}", True, (0, 0, 0))
        screen.blit(score_text, (10, 10))

        pygame.display.update()
        clock.tick(30)

game_loop()
pygame.quit()
