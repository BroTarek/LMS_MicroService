import React from 'react'
type CategoriesPillProps={
    title:string
}
const CategoriesPill = ({title}:CategoriesPillProps) => {
    return (
        <>
            <button
                className="px-6 py-2.5 bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest rounded-full text-sm font-semibold transition-all">{title}</button>
        </>
    )
}

export default CategoriesPill