import cv2
import os
import numpy as np
import random

input_folder = r"C:\Users\User\Desktop\Anthracnose"
output_folder = r"C:\Users\User\Desktop\Anthracnose_augmented"

os.makedirs(output_folder, exist_ok=True)

counter = 1

def get_name(prefix, counter):
    return f"{prefix}_{counter:04d}.jpg"

for filename in sorted(os.listdir(input_folder)):
    if filename.endswith((".jpg", ".png", ".jpeg")):
        path = os.path.join(input_folder, filename)
        img = cv2.imread(path)

        # -------------------------
        # ORIGINAL
        # -------------------------
        cv2.imwrite(os.path.join(output_folder, get_name("Normal", counter)), img)

        # -------------------------
        # HORIZONTAL FLIP
        # -------------------------
        flip_h = cv2.flip(img, 1)
        cv2.imwrite(os.path.join(output_folder, get_name("Flipped_horz", counter)), flip_h)

        # -------------------------
        # VERTICAL FLIP
        # -------------------------
        flip_v = cv2.flip(img, 0)
        cv2.imwrite(os.path.join(output_folder, get_name("Flipped_vert", counter)), flip_v)

        # -------------------------
        # ROTATION
        # -------------------------
        (h, w) = img.shape[:2]
        M = cv2.getRotationMatrix2D((w//2, h//2), 30, 1.0)
        rotated = cv2.warpAffine(img, M, (w, h))
        cv2.imwrite(os.path.join(output_folder, get_name("Rotated", counter)), rotated)

        # -------------------------
        # BRIGHTNESS
        # -------------------------
        bright = cv2.convertScaleAbs(img, alpha=1.2, beta=30)
        cv2.imwrite(os.path.join(output_folder, get_name("Brightened", counter)), bright)

        # -------------------------
        # INVERT
        # -------------------------
        invert = cv2.bitwise_not(img)
        cv2.imwrite(os.path.join(output_folder, get_name("Inverted", counter)), invert)

        # -------------------------
        # BLUR
        # -------------------------
        blur = cv2.GaussianBlur(img, (5,5), 0)
        cv2.imwrite(os.path.join(output_folder, get_name("Blured", counter)), blur)

        # -------------------------
        # NOISE
        # -------------------------
        noise = img + np.random.normal(0, 25, img.shape).astype(np.uint8)
        cv2.imwrite(os.path.join(output_folder, get_name("Noisy", counter)), noise)

        # -------------------------
        # CROP
        # -------------------------
        crop_h, crop_w = int(h*0.8), int(w*0.8)
        x = random.randint(0, w - crop_w)
        y = random.randint(0, h - crop_h)

        crop = img[y:y+crop_h, x:x+crop_w]
        crop = cv2.resize(crop, (w, h))  # resize back to original size

        cv2.imwrite(os.path.join(output_folder, get_name("Cropped", counter)), crop)

        # -------------------------
        # ZOOM
        # -------------------------
        zoom = cv2.resize(img, None, fx=1.2, fy=1.2)

        zh, zw = zoom.shape[:2]

        # center crop back to original size
        start_x = (zw - w) // 2
        start_y = (zh - h) // 2

        zoom_cropped = zoom[start_y:start_y+h, start_x:start_x+w]

        cv2.imwrite(os.path.join(output_folder, get_name("Zoomed", counter)), zoom_cropped)

        # Increment counter
        counter += 1

print("✅ Done !")