import React from 'react'
type StatsItemProps={
    value:number,
    describtion:string
}
const StatsItem = ({describtion,value}:StatsItemProps) => {
  return (
    <div className="text-center flex flex-col items-center">
              <span className="text-4xl font-extrabold text-primary mb-2">{value}+</span>
              <span className="text-on-surface-variant font-medium">{describtion}</span>
            </div>
  )
}

export default StatsItem