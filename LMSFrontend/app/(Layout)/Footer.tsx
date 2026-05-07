import React from 'react'

const Footer = () => {
  return (<>
   <footer className="bg-slate-50 dark:bg-slate-950 w-full pt-20 pb-10 mt-20">
        <div className="max-w-screen-2xl mx-auto px-8">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
                <div className="col-span-1 md:col-span-1 text-left">
                    <a className="text-3xl font-extrabold text-[#003366] dark:text-blue-500 block mb-6" href="#">Yanfaa</a>
                    <p className="text-slate-500 leading-relaxed text-sm mb-6">
                        An Arabic educational platform aiming to empower Arab youth by providing high-quality
                        educational content in various practical and creative fields.
                    </p>
                    <div className="flex flex-row gap-4">
                        <span
                            className="material-symbols-outlined text-slate-400 hover:text-primary cursor-pointer transition-colors">social_leaderboard</span>
                        <span
                            className="material-symbols-outlined text-slate-400 hover:text-primary cursor-pointer transition-colors">language</span>
                        <span
                            className="material-symbols-outlined text-slate-400 hover:text-primary cursor-pointer transition-colors">mail</span>
                    </div>
                </div>
                <div className="text-left">
                    <h4 className="font-bold text-primary mb-6">Platform</h4>
                    <ul className="space-y-4">
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">About
                                Yanfaa</a></li>
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Courses</a>
                        </li>
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Mentors</a>
                        </li>
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Learning
                                Paths</a></li>
                    </ul>
                </div>
                <div className="text-left">
                    <h4 className="font-bold text-primary mb-6">Support</h4>
                    <ul className="space-y-4">
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Help
                                Center</a></li>
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Privacy
                                Policy</a></li>
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Terms of
                                Use</a></li>
                        <li><a className="text-slate-500 text-sm hover:text-primary transition-colors" href="#">Contact
                                Us</a></li>
                    </ul>
                </div>
                <div className="text-left">
                    <h4 className="font-bold text-primary mb-6">Download App</h4>
                    <div className="space-y-3">
                        <div
                            className="bg-primary text-white p-3 rounded-xl flex items-center justify-between cursor-pointer hover:opacity-90 transition-opacity">
                            <span className="material-symbols-outlined">phone_iphone</span>
                            <div className="text-left">
                                <p className="text-[10px] opacity-80">Download on</p>
                                <p className="text-sm font-bold">App Store</p>
                            </div>
                        </div>
                        <div
                            className="bg-primary text-white p-3 rounded-xl flex items-center justify-between cursor-pointer hover:opacity-90 transition-opacity">
                            <span className="material-symbols-outlined">play_arrow</span>
                            <div className="text-left">
                                <p className="text-[10px] opacity-80">Get it on</p>
                                <p className="text-sm font-bold">Google Play</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div className="pt-8 border-t border-slate-200 text-center">
                <p className="text-slate-500 text-sm font-['Manrope']">© 2024 Yanfaa Mentorship Platform. All scholarly
                    rights reserved.</p>
            </div>
        </div>
    </footer>
  </>
  )
}

export default Footer