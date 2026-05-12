#!/bin/bash
# Конвертация landing-изображений в WebP с правильными размерами
# Требуется: cwebp (sudo apt install webp)
# Запуск: bash scripts/optimize-images.sh

LANDING_DIR="web/landing"

echo "=== Оптимизация изображений для SEO ==="
echo ""

# kiber_nuar.jpg — 234KB, контейнер 654x489
echo "[1/4] kiber_nuar.jpg → kiber_nuar.webp (resize 654x489)"
cwebp -q 82 -resize 654 489 "$LANDING_DIR/kiber_nuar.jpg" -o "$LANDING_DIR/kiber_nuar.webp"
echo "  Размер до: $(du -h $LANDING_DIR/kiber_nuar.jpg | cut -f1)"
echo "  Размер после: $(du -h $LANDING_DIR/kiber_nuar.webp | cut -f1)"

# romance.jpg — 190KB
echo "[2/4] romance.jpg → romance.webp"
cwebp -q 82 -resize 654 489 "$LANDING_DIR/romance.jpg" -o "$LANDING_DIR/romance.webp"
echo "  Размер до: $(du -h $LANDING_DIR/romance.jpg | cut -f1)"
echo "  Размер после: $(du -h $LANDING_DIR/romance.webp | cut -f1)"

# dark_fantasy.jpg — 135KB
echo "[3/4] dark_fantasy.jpg → dark_fantasy.webp"
cwebp -q 82 -resize 654 489 "$LANDING_DIR/dark_fantasy.jpg" -o "$LANDING_DIR/dark_fantasy.webp"
echo "  Размер до: $(du -h $LANDING_DIR/dark_fantasy.jpg | cut -f1)"
echo "  Размер после: $(du -h $LANDING_DIR/dark_fantasy.webp | cut -f1)"

# master_img.jpg — 133KB, контейнер 92x50
echo "[4/4] master_img.jpg → master_img.webp (resize 92x50)"
cwebp -q 85 -resize 92 50 "$LANDING_DIR/master_img.jpg" -o "$LANDING_DIR/master_img.webp"
echo "  Размер до: $(du -h $LANDING_DIR/master_img.jpg | cut -f1)"
echo "  Размер после: $(du -h $LANDING_DIR/master_img.webp | cut -f1)"

# feedback_bg.webp — уже WebP, но большой (117KB), просто пережимаем
echo "[5/5] feedback_bg.webp → feedback_bg.webp (пережатие)"
cwebp -q 60 "$LANDING_DIR/feedback_bg.webp" -o "$LANDING_DIR/feedback_bg_new.webp"
mv "$LANDING_DIR/feedback_bg_new.webp" "$LANDING_DIR/feedback_bg.webp"
echo "  Размер после: $(du -h $LANDING_DIR/feedback_bg.webp | cut -f1)"

echo ""
echo "=== Готово! ==="
echo "Не забудь обновить ссылки в web/index.html:"
echo "  landing/kiber_nuar.jpg  → landing/kiber_nuar.webp"
echo "  landing/romance.jpg     → landing/romance.webp"
echo "  landing/dark_fantasy.jpg → landing/dark_fantasy.webp"
echo "  landing/master_img.jpg  → landing/master_img.webp"
