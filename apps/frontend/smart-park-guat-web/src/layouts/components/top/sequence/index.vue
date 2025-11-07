<template>
  <div class="headers">
    <canvas ref="animation_canvas" class="animation_canvas" id="animation_canvas"></canvas>
    <div class="headersBody">
      <div class="headerTitle">
        <span>{{ name }}</span>
      </div>
    </div>
  </div>
</template>

<script>
import firstImage from './topbg/0.png';

export default {
  name: 'Sequence',
  props: {
    name: {
      type: String,
      default() {
        return '';
      },
    },
    // 文件数量
    fileLength: {
      type: Number,
      default() {
        return 74;
      },
    },
    // 动画间隔
    IntervalTime: {
      type: Number,
      default() {
        return 80;
      },
    },
  },
  data() {
    return {};
  },
  async mounted() {
    var that = this;
    await that.Sequence();
  },
  methods: {
    async Sequence() {
      var that = this;
      //初始化参数
      var canvas = this.$refs.animation_canvas;
      var width = canvas.offsetWidth;
      var height = canvas.offsetHeight;
      var ctx = canvas.getContext('2d');

      canvas.width = width;
      canvas.height = height;
      var sources = [];
      sources.push(firstImage); // 使用静态导入的 firstImage

      //立即渲染第一张图片
      var initialImage = new Image();
      initialImage.src = firstImage; // 直接使用 firstImage，不需要 .default
      initialImage.onload = function () {
        ctx.drawImage(initialImage, 0, 0, width, height);
      };

      //加载其他所有图片
      for (let i = 1; i <= that.fileLength; i++) {
        const image = await import(`./topbg/${i}.png`);
        sources.push(image.default);
      }

      function loadImages(sources, callback) {
        var loadedImages = 0;
        var numImages = sources.length;
        var images = [];
        for (var i = 0, len = sources.length; i < len; i++) {
          images[i] = new Image();
          images[i].onload = function () {
            if (++loadedImages >= numImages) {
              callback(images);
              that.backgroundImageLoaded = false;
            }
          };
          images[i].src = sources[i];
        }
      }

      function playImages(images) {
        var imageNum = images.length;
        var imageNow = 0;
        setInterval(function () {
          ctx.clearRect(0, 0, width, height);
          ctx.drawImage(images[imageNow], 0, 0, width, height);
          imageNow++;
          if (imageNow >= imageNum) {
            imageNow = 0;
          }
        }, that.IntervalTime);
      }

      loadImages(sources, function (images) {
        playImages(images);
      });
    },
  },
};
</script>

<style scoped lang="scss">
.headers {
  display: flex;
  position: absolute;
  top: 0;
  left: 0;
  flex-flow: row nowrap;
  align-items: flex-start;
  width: 100%;
  height: 100px;
  place-content: flex-start space-between;
}

.headersBody {
  display: flex;
  position: relative;
  z-index: 10;
  flex-flow: row nowrap;
  place-content: flex-start center;
  align-items: center;
  width: 100%;
  height: 100%;

  .headerTitle {
    display: flex;
    position: relative;
    z-index: 100;
    flex-flow: row nowrap;
    place-content: flex-start center;
    align-items: flex-start;
    width: 50%;
    height: 100%;

    span {
      z-index: 1;
      margin: 0 auto;
      padding-top: 10px;
      color: #fff;
      font-size: 42px;
      font-weight: 800;
      letter-spacing: 8px;
      text-align: center;
      text-shadow: 5px 5px 5px #000;
    }
  }
}

.animation_canvas {
  position: absolute;
  z-index: -1;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
</style>
