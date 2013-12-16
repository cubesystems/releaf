// constructor
function url_builder( params )
{
	if( params === undefined )
	{
		params = {};
	}
	var keepCurrentQuery = true;
	if( params === false || params.baseUrl !== undefined )
	{
		keepCurrentQuery = false;
	}
	if( typeof params == 'string' )
	{
		params = { baseUrl: params };
	}
	// setup members
	this.path = '';
	this.query = {};
	// get url
	var baseUrl = params.baseUrl || location.href;
	// remove anchor
	baseUrl = baseUrl.split( '#' ).shift();
	// split url
	var urlParts = baseUrl.split( '?' );
	this.path = urlParts.shift();
	if( keepCurrentQuery && urlParts.length > 0 )
	{
		var queryParts = urlParts.shift().split( '&' );
		for( var i = 0; i < queryParts.length; i++ )
		{
			if( queryParts[ i ].length > 0 )
			{
				var variable = queryParts[ i ].split( '=' );
				var name = variable.shift();

				if( variable.length > 0 )
				{
					var value = variable.shift();
				}
				else
				{
					var value = '';
				}

				if( unescape( name ).substr( unescape( name ).length - 2, 2 ) == '[]' )
				{
					name = unescape( name );
				}

				if( name.substr( name.length - 2, 2 ) == '[]' )
				{
					name = name.substr( 0, name.length - 2 );
					if( this.query[ name ] === undefined || !(this.query[ name ] instanceof Array) )
					{
						this.query[ name ] = [];
					}
					this.query[ name ].push( value );
				}
				else
				{
					this.query[ name ] = value;
				}
			}
		}
	}
	if( params.keep !== undefined && params.keep instanceof Array )
	{
		var filteredQuery = {};
		for( var i = 0; i < params.keep.length; i++ )
		{
			if( this.query[ params.keep[i] ] !== undefined )
			{
				filteredQuery[ params.keep[i] ] = this.query[ params.keep[i] ];
			}
		}
		this.query = filteredQuery;
	}
}

url_builder.prototype.add = function( params, value )
{
	if( params instanceof Array )
	{
		for( var i = 0; i < params.length; i++ )
		{
			if( params[ i ].name !== undefined && params[ i ].value !== undefined )
			{
				var name = params[ i ].name;
				if( name.substr( name.length - 2, 2 ) == '[]' )
				{
					name = name.substr( 0, name.length - 2 );
					if( this.query[ name ] === undefined || !(this.query[ name ] instanceof Array) )
					{
						this.query[ name ] = [];
					}
					this.query[ name ].push( params[ i ].value );
				}
				else
				{
					this.query[ params[ i ].name ] = params[ i ].value;
				}
			}
		}
	}
	else if( params instanceof Object )
	{
		for( var i in params )
		{
			this.query[ i ] = params[ i ];
		}
	}
	else if( typeof params == 'string' )
	{
		if( value === undefined )
		{
			var temp = new url_builder( '?' + params );
			for( var i in temp.query )
			{
				this.query[ i ] = temp.query[i];
			}
		}
		else
		{
			this.query[ params ] = value;
		}
	}
	return this;
}

url_builder.prototype.removeAll = function( preserveParams )
{
    for( var i in this.query )
    {
        if( preserveParams === undefined || jQuery.inArray(i, preserveParams) == -1 )
        {
            this.remove(i);
        }
    }
	return this;
}

url_builder.prototype.remove = function( name )
{
	delete this.query[ name ];
	return this;
}

url_builder.prototype.get = function( name )
{
	if( this.query[ name ] !== undefined )
	{
		return this.query[ name ];
	}
	return null;
}

url_builder.prototype.getUrl = function()
{
	var query = '';
	var isFirst = true;
	for( var i in this.query )
	{
		if( !isFirst )
		{
			query += '&';
		}
		else
		{
			isFirst = false;
		}
		if( this.query[ i ] instanceof Array )
		{
			query += i + '[]=' + this.query[ i ].map(function(s){ return encodeURIComponent(s); }).join( '&' + i + '[]=' );
		}
		else
		{
			query += i + '=' + encodeURIComponent(this.query[ i ]);
		}
	}

	return this.path + '?' + query;
}
