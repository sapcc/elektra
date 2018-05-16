/*
 * This component is used to highlight a substring in a given text.
 * Usage: <SearchHighlight term='test'>A test text</SearchHighlight>
 */
export const SearchHighlight = ({children,term,text}) => {
  text = text || children

  if(!text) return null
  if(!term || term.length==0) return text

  const index = text.toLowerCase().indexOf(term.toLowerCase())
  if(index<0) return text

  return (
    <React.Fragment>
      {text.substring(0, index) }
      <span className='highlight'>
        {text.substring(index,index+term.length)}
      </span>
      {text.substring(index + term.length)}
    </React.Fragment>
  )
}
