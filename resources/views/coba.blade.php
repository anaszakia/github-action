<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - Selamat Datang</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
            background: #0a0a0a;
            color: #fff;
        }

        .container {
            position: relative;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            overflow: hidden;
        }

        .bg-animation {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        .shape {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            animation: float 20s infinite ease-in-out;
        }

        .shape:nth-child(1) {
            width: 300px;
            height: 300px;
            top: -150px;
            left: -150px;
            animation-delay: 0s;
        }

        .shape:nth-child(2) {
            width: 200px;
            height: 200px;
            top: 50%;
            right: -100px;
            animation-delay: 4s;
        }

        .shape:nth-child(3) {
            width: 400px;
            height: 400px;
            bottom: -200px;
            left: 30%;
            animation-delay: 2s;
        }

        @keyframes float {
            0%, 100% {
                transform: translate(0, 0) rotate(0deg);
            }
            33% {
                transform: translate(30px, -50px) rotate(120deg);
            }
            66% {
                transform: translate(-20px, 20px) rotate(240deg);
            }
        }

        .content {
            position: relative;
            z-index: 10;
            text-align: center;
            padding: 40px;
            max-width: 800px;
            backdrop-filter: blur(10px);
            background: rgba(255, 255, 255, 0.1);
            border-radius: 30px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: fadeInUp 1s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .logo {
            width: 80px;
            height: 80px;
            margin: 0 auto 30px;
            background: linear-gradient(135deg, #fff 0%, #f0f0f0 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            font-weight: bold;
            color: #667eea;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }

        h1 {
            font-size: 3.5em;
            margin-bottom: 20px;
            background: linear-gradient(90deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 700;
            letter-spacing: -1px;
        }

        p {
            font-size: 1.3em;
            margin-bottom: 40px;
            color: rgba(255, 255, 255, 0.9);
            line-height: 1.6;
        }

        .btn-group {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 15px 40px;
            font-size: 1.1em;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #fff;
            color: #667eea;
            box-shadow: 0 10px 25px rgba(255, 255, 255, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(255, 255, 255, 0.4);
        }

        .btn-secondary {
            background: transparent;
            color: #fff;
            border: 2px solid #fff;
        }

        .btn-secondary:hover {
            background: #fff;
            color: #667eea;
            transform: translateY(-3px);
        }

        .features {
            display: flex;
            gap: 30px;
            margin-top: 50px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .feature {
            flex: 1;
            min-width: 150px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }

        .feature:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-5px);
        }

        .feature-icon {
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .feature-title {
            font-size: 1.1em;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .feature-desc {
            font-size: 0.9em;
            color: rgba(255, 255, 255, 0.7);
        }

        @media (max-width: 768px) {
            h1 {
                font-size: 2.5em;
            }
            
            p {
                font-size: 1.1em;
            }
            
            .btn-group {
                flex-direction: column;
            }
            
            .features {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="bg-animation">
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
        </div>
        
        <div class="content">
            <div class="logo">W</div>
            <h1>Selamat Datang</h1>
            <p>Temukan pengalaman digital yang luar biasa dengan desain modern dan elegan yang kami tawarkan untuk Anda</p>
            
            <div class="btn-group">
                <button class="btn btn-primary" onclick="alert('Memulai perjalanan Anda!')">Mulai Sekarang</button>
                <button class="btn btn-secondary" onclick="alert('Pelajari lebih lanjut!')">Pelajari Lebih Lanjut</button>
            </div>
            
            <div class="features">
                <div class="feature">
                    <div class="feature-icon">⚡</div>
                    <div class="feature-title">Cepat</div>
                    <div class="feature-desc">Performa optimal</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">🎨</div>
                    <div class="feature-title">Elegan</div>
                    <div class="feature-desc">Desain memukau</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">🔒</div>
                    <div class="feature-title">Aman</div>
                    <div class="feature-desc">Terlindungi penuh</div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>