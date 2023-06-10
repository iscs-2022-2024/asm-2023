import cv2

def extract_square(input_image_path, output_image_path):
    # Charger l'image d'entrée en utilisant OpenCV
    image = cv2.imread(input_image_path)

    # Vérifier si l'image a été chargée correctement
    if image is None:
        raise ValueError("Impossible de charger l'image.")

    # Extraire un carré de 32x32 pixels au centre de l'image
    height, width, _ = image.shape
    left = 9
    top = 2
    right = left + 4
    bottom = top + 4
    square_image = image[top:bottom, left:right]

    # Enregistrer l'image carrée au format JPG en utilisant OpenCV
    cv2.imwrite(output_image_path, square_image)
    cv2.imwrite("small_duck.png", image)

    print("Carré extrait et enregistré avec succès !")

# Exemple d'utilisation
input_path = 'small_duck.png'
output_path = 'duck_pattern.png'
extract_square(input_path, output_path)
