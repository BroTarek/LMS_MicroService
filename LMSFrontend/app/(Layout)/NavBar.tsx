"use client"
import Link from 'next/link'
import React, { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'

const NavBar = () => {
  const router = useRouter()
  const [user, setUser] = useState<any>(null)

  useEffect(() => {
    const userData = localStorage.getItem('user')
    if (userData) {
      setUser(JSON.parse(userData))
    }
  }, [])

  const handleLogout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    setUser(null)
    router.push('/Login')
  }

  return (
    <nav className="fixed top-0 w-full z-50 bg-white/80 backdrop-blur-[20px] shadow-sm border-b border-outline-variant/20">
      <div className="flex items-center justify-between px-8 py-4 max-w-screen-2xl mx-auto">
        <div className="flex items-center gap-8">
          <Link className="text-2xl font-extrabold tracking-tighter text-primary" href="/">Yanfaa</Link>
          <div className="hidden md:flex items-center gap-6">
            <Link className="text-on-surface-variant font-bold hover:text-primary transition-all" href="/">Home</Link>
            {user?.role === 'TEACHER' ? (
              <Link className="text-on-surface-variant font-medium hover:text-primary transition-all" href="/Teacher">Teacher Dashboard</Link>
            ) : user?.role === 'STUDENT' ? (
              <Link className="text-on-surface-variant font-medium hover:text-primary transition-all" href="/Student">My Learning</Link>
            ) : null}
          </div>
        </div>
        
        <div className="flex items-center gap-4">
          {user ? (
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center font-bold text-xs">
                  {user.username.charAt(0).toUpperCase()}
                </div>
                <span className="text-sm font-bold text-primary">{user.username}</span>
              </div>
              <button 
                onClick={handleLogout}
                className="px-4 py-2 text-xs font-bold text-red-600 hover:bg-red-50 rounded-full transition-all"
              >
                Logout
              </button>
            </div>
          ) : (
            <>
              <Link href="/Login" className="px-5 py-2 text-sm font-semibold text-primary hover:bg-surface-container-low rounded-full transition-all">Login</Link>
              <Link href="/Registeration" className="px-6 py-2.5 bg-primary text-on-primary text-sm font-bold rounded-full hover:shadow-lg active:scale-95 transition-all">Get Started</Link>
            </>
          )}
        </div>
      </div>
    </nav>
  )
}

export default NavBar
