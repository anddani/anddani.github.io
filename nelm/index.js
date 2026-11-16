// Boot the Elm app and wire the canvas-render port.
const app = Elm.Main.init({
    node: document.getElementById("elm"),
});

const canvas = document.getElementById("screen");
const ctx = canvas.getContext("2d");

// NES master palette: 64 entries, each [R, G, B]. Standard Nesdev RP2C02.
// Indices 0x0D, 0x0E, 0x0F, 0x1D-0x1F, 0x2E-0x2F, 0x3E-0x3F are "black" / unused.
const PALETTE = [
    [ 84,  84,  84], [  0,  30, 116], [  8,  16, 144], [ 48,   0, 136],
    [ 68,   0, 100], [ 92,   0,  48], [ 84,   4,   0], [ 60,  24,   0],
    [ 32,  42,   0], [  8,  58,   0], [  0,  64,   0], [  0,  60,   0],
    [  0,  50,  60], [  0,   0,   0], [  0,   0,   0], [  0,   0,   0],
    [152, 150, 152], [  8,  76, 196], [ 48,  50, 236], [ 92,  30, 228],
    [136,  20, 176], [160,  20, 100], [152,  34,  32], [120,  60,   0],
    [ 84,  90,   0], [ 40, 114,   0], [  8, 124,   0], [  0, 118,  40],
    [  0, 102, 120], [  0,   0,   0], [  0,   0,   0], [  0,   0,   0],
    [236, 238, 236], [ 76, 154, 236], [120, 124, 236], [176,  98, 236],
    [228,  84, 236], [236,  88, 180], [236, 106, 100], [212, 136,  32],
    [160, 170,   0], [116, 196,   0], [ 76, 208,  32], [ 56, 204, 108],
    [ 56, 180, 204], [ 60,  60,  60], [  0,   0,   0], [  0,   0,   0],
    [236, 238, 236], [168, 204, 236], [188, 188, 236], [212, 178, 236],
    [236, 174, 236], [236, 174, 212], [236, 180, 176], [228, 196, 144],
    [204, 210, 120], [180, 222, 120], [168, 226, 144], [152, 226, 180],
    [160, 214, 228], [160, 162, 160], [  0,   0,   0], [  0,   0,   0],
];

// Receives a flat array of palette indices (length 256*240 = 61_440).
// Look up the RGB triple per index and write to ImageData.
const imageData = ctx.createImageData(256, 240);
const pixels = imageData.data;

// Framebuffer arrives as a nested JS array: 240 rows of 256 palette indices.
app.ports.renderFramebuffer.subscribe(function (rows) {
    let j = 0;
    for (let y = 0; y < 240; y++) {
        const row = rows[y];
        for (let x = 0; x < 256; x++, j += 4) {
            const rgb = PALETTE[row[x] & 0x3F];
            pixels[j + 0] = rgb[0];
            pixels[j + 1] = rgb[1];
            pixels[j + 2] = rgb[2];
            pixels[j + 3] = 255;
        }
    }
    ctx.putImageData(imageData, 0, 0);
});
