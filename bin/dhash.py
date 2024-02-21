"""dHash is originally from http://blog.iconfinder.com/detecting-duplicate-images-using-python/
and is intended to find similar images.
"""

from PIL import Image # Use Pillow for Python 3.x

def dhash(img_path):
    x = Image.open(img_path)
    return _dhash(x)

def _dhash(image, hash_size = 8):
    """Computer dHash of an image.

    # example of use
    >>> from PIL import Image
    >>> import dhash, hamming_distance
    >>> orig = Image.open('data/cat_grumpy_orig.png')
    >>> modif = Image.open('data/cat_grumpy_modif.png')
    >>> dhash(orig)
    '4c8e3366c275650f'
    >>> dhash(modif)
    '4c8e3366c275650f'
    >>> dhash(orig) == dhash(modif)
    True
    """
    # Grayscale and shrink the image in one step.
    image = image.convert('L').resize(
        (hash_size + 1, hash_size),
        Image.ANTIALIAS,
    )

    pixels = list(image.getdata())

    # Compare adjacent pixels.
    difference = []
    for row in range(hash_size):
        for col in range(hash_size):
            pixel_left = image.getpixel((col, row))
            pixel_right = image.getpixel((col + 1, row))
            difference.append(pixel_left > pixel_right)

    # Convert the binary array to a hexadecimal string.
    decimal_value = 0
    hex_string = []
    for index, value in enumerate(difference):
        if value:
            decimal_value += 2**(index % 8)
        if (index % 8) == 7:
            hex_string.append(hex(decimal_value)[2:].rjust(2, '0'))
            decimal_value = 0

    return ''.join(hex_string)