import cv2
import os

input_folder = r"C:\Users\User\Desktop\Anthracnose"
output_folder = r"C:\Users\User\Desktop\Anthracnose_resized"

os.makedirs(output_folder, exist_ok=True)

for file in os.listdir(input_folder):
    if file.endswith((".jpeg")):
        img = cv2.imread(os.path.join(input_folder, file))
        resized = cv2.resize(img, (224, 224))
        cv2.imwrite(os.path.join(output_folder, file), resized)

print("Done ✅")