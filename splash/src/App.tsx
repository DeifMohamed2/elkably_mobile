import { motion } from 'motion/react';
import { useState } from 'react';
import { Sun, Moon } from 'lucide-react';
import logo from 'figma:asset/81a73ee234c8431b2bfec30d59ca10b403fc5c00.png';

export default function App() {
  const [isDark, setIsDark] = useState(true);

  return (
    <div className={`min-h-screen flex items-center justify-center overflow-hidden transition-colors duration-700 ${
      isDark 
        ? 'bg-gradient-to-br from-gray-900 via-gray-800 to-black' 
        : 'bg-gradient-to-br from-red-50 via-white to-red-100'
    }`}>
      {/* Theme Toggle Button */}
      <motion.button
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2.5, duration: 0.5 }}
        onClick={() => setIsDark(!isDark)}
        className={`fixed top-8 right-8 z-20 p-4 rounded-full transition-all duration-300 ${
          isDark 
            ? 'bg-white/10 hover:bg-white/20 text-white' 
            : 'bg-red-100 hover:bg-red-200 text-red-600'
        }`}
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.95 }}
      >
        <motion.div
          initial={false}
          animate={{ rotate: isDark ? 0 : 180 }}
          transition={{ duration: 0.5, ease: "easeInOut" }}
        >
          {isDark ? <Sun className="w-6 h-6" /> : <Moon className="w-6 h-6" />}
        </motion.div>
      </motion.button>

      {/* Animated background circles */}
      <motion.div
        className={`absolute w-96 h-96 rounded-full blur-3xl ${
          isDark ? 'bg-red-600/10' : 'bg-red-500/20'
        }`}
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.3, 0.5, 0.3],
        }}
        transition={{
          duration: 4,
          repeat: Infinity,
          ease: "easeInOut",
        }}
      />
      
      <div className="relative z-10 flex flex-col items-center gap-8">
        {/* Logo Animation */}
        <motion.div
          initial={{ scale: 0, opacity: 0, rotate: -180 }}
          animate={{ scale: 1, opacity: 1, rotate: 0 }}
          transition={{
            duration: 1.2,
            ease: [0.34, 1.56, 0.64, 1],
            delay: 0.2,
          }}
          className="relative"
        >
          <motion.img
            src={logo}
            alt="ELKABLY Logo"
            className="w-48 h-48 md:w-64 md:h-64 object-contain"
            animate={{
              y: [0, -10, 0],
            }}
            transition={{
              duration: 3,
              repeat: Infinity,
              ease: "easeInOut",
              delay: 1.5,
            }}
          />
          
          {/* Glow effect */}
          <motion.div
            className={`absolute inset-0 rounded-full blur-2xl ${
              isDark ? 'bg-red-600/20' : 'bg-red-500/30'
            }`}
            animate={{
              scale: [1, 1.3, 1],
              opacity: isDark ? [0.5, 0.8, 0.5] : [0.3, 0.6, 0.3],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
        </motion.div>

        {/* Brand Name Animation */}
        <div className="flex gap-1">
          {['E', 'L', 'K', 'A', 'B', 'L', 'Y'].map((letter, index) => (
            <motion.span
              key={index}
              initial={{ opacity: 0, y: 50 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{
                duration: 0.5,
                delay: 0.8 + index * 0.1,
                ease: [0.34, 1.56, 0.64, 1],
              }}
              className={`text-5xl md:text-6xl font-bold tracking-wider transition-colors duration-700 ${
                isDark ? 'text-white' : 'text-red-600'
              }`}
            >
              {letter}
            </motion.span>
          ))}
        </div>

        {/* Loading indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 2, duration: 0.5 }}
          className="flex gap-2 mt-4"
        >
          {[0, 1, 2].map((index) => (
            <motion.div
              key={index}
              className="w-2 h-2 bg-red-600 rounded-full"
              animate={{
                scale: [1, 1.5, 1],
                opacity: [0.5, 1, 0.5],
              }}
              transition={{
                duration: 1,
                repeat: Infinity,
                delay: index * 0.2,
                ease: "easeInOut",
              }}
            />
          ))}
        </motion.div>
      </div>
    </div>
  );
}