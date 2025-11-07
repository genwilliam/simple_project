// 后端跑路了
// 只能自强了
// fuck nodejs + express + cors😭
import express from 'express';
import cors from 'cors';
const app = express();
const port = 3000;

app.use(cors());
// 定义接口
app.get('/api/alarm', (req, res) => {
  const response = {
    code: 200,
    msg: 'success',
    data: [
      {
        deviceId: 'CP0001',
        alarmType: 'over_current',
        alarmLevel: '普通',
        alarmTime: '2025-10-29T03:22:36.000+00:00',
        status: 0,
      },
      {
        deviceId: 'CP0002',
        alarmType: '我要发财了',
        alarmLevel: '危险',
        alarmTime: '2025-10-29T03:23:06.000+00:00',
        status: 0,
      },
    ],
  };

  res.json(response); // 返回 JSON
});

// 启动服务器
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
